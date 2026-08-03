import SwiftUI

/// Wired to the sidebar's existing `.settings` destination, which (like
/// `.statistics` before Phase 4.5 and `.resources` before it was removed)
/// had no real screen behind it. Starts minimal — the one setting that
/// actually exists right now is the week-start preference (requested
/// alongside the Analytics heatmap); more can be added here as they come up.
struct SettingsView: View {
    let userPreferences: UserPreferences
    let notificationManager: any NotificationSchedulingProtocol
    let calendarSyncService: any CalendarSyncServiceProtocol

    @State private var viewModel: SettingsViewModel
    @State private var availableCalendars: [ExternalCalendarInfo] = []
    @State private var hasCalendarAccess = false

    init(
        userPreferences: UserPreferences,
        notificationManager: any NotificationSchedulingProtocol,
        calendarSyncService: any CalendarSyncServiceProtocol,
        appState: AppState,
        courseRepository: any CourseRepositoryProtocol,
        lectureRepository: any LectureRepositoryProtocol,
        calendarRepository: any CalendarRepositoryProtocol
    ) {
        self.userPreferences = userPreferences
        self.notificationManager = notificationManager
        self.calendarSyncService = calendarSyncService
        _viewModel = State(wrappedValue: SettingsViewModel(
            appState: appState,
            courseRepository: courseRepository,
            lectureRepository: lectureRepository,
            calendarRepository: calendarRepository,
            calendarSyncService: calendarSyncService,
            userPreferences: userPreferences
        ))
    }

    var body: some View {
        Form {
            Section {
                TextField("Your Name", text: Binding(
                    get: { userPreferences.userName },
                    set: { userPreferences.userName = $0 }
                ))
            } header: {
                ListSectionHeaderLabel(title: "Profile", icon: "person.fill", tint: .blue)
            } footer: {
                Text("Shown in Home's greeting. Leave blank to skip it.")
            }

            Section {
                Picker("Appearance", selection: Binding(
                    get: { userPreferences.appearance },
                    set: { userPreferences.appearance = $0 }
                )) {
                    ForEach(AppearancePreference.allCases) { option in
                        Text(option.label).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            } header: {
                ListSectionHeaderLabel(title: "Appearance", icon: "circle.righthalf.filled", tint: .purple)
            }

            Section {
                Toggle("Week Starts on Monday", isOn: Binding(
                    get: { userPreferences.weekStartsOnMonday },
                    set: { userPreferences.weekStartsOnMonday = $0 }
                ))
            } header: {
                ListSectionHeaderLabel(title: "Calendar", icon: "calendar", tint: .orange)
            } footer: {
                Text("Controls how \"This Week\" and the Analytics heatmap group days into weeks. Off uses Sunday as the first day instead.")
            }

            Section {
                Picker("Default Duration", selection: Binding(
                    get: { userPreferences.defaultLectureDurationMinutes },
                    set: { userPreferences.defaultLectureDurationMinutes = $0 }
                )) {
                    ForEach(Self.lectureDurationOptions, id: \.self) { minutes in
                        Text(StudyTimeFormatter.label(minutes: minutes)).tag(minutes)
                    }
                }

                if hasCalendarAccess {
                    Picker("Lectures Calendar", selection: Binding(
                        get: { userPreferences.lectureSourceCalendarIdentifier },
                        set: { userPreferences.lectureSourceCalendarIdentifier = $0 }
                    )) {
                        Text("None").tag(nil as String?)
                        ForEach(availableCalendars) { calendar in
                            Text(calendar.title).tag(Optional(calendar.id))
                        }
                    }
                } else {
                    Button("Allow Calendar Access") {
                        Task {
                            hasCalendarAccess = await calendarSyncService.requestEventAccess()
                            if hasCalendarAccess {
                                availableCalendars = calendarSyncService.availableEventCalendars()
                            }
                        }
                    }
                }

                if userPreferences.lectureSourceCalendarIdentifier != nil {
                    Button {
                        viewModel.syncAllLectures()
                    } label: {
                        if viewModel.isSyncingLectures {
                            Label("Syncing…", systemImage: "arrow.triangle.2.circlepath")
                        } else {
                            Label("Sync Lectures Now", systemImage: "arrow.triangle.2.circlepath")
                        }
                    }
                    .disabled(viewModel.isSyncingLectures)

                    if let summary = viewModel.lastSyncSummary {
                        Text(summary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            } header: {
                ListSectionHeaderLabel(title: "Lectures", icon: "list.bullet", tint: .pink)
            } footer: {
                Text("One calendar covers every course — events are matched to a course automatically when their title contains that course's name or code (e.g. \"CS201 Lecture\" matches course code CS201). Events that don't match any course are skipped. That calendar stays the source of truth; StudyHub only mirrors it, never writes back.")
            }

            Section {
                Toggle("Enable Notifications", isOn: Binding(
                    get: { userPreferences.notificationsEnabled },
                    set: { newValue in
                        userPreferences.notificationsEnabled = newValue
                        if newValue {
                            Task { _ = await notificationManager.requestAuthorization() }
                        }
                    }
                ))

                if userPreferences.notificationsEnabled {
                    Picker("Remind Me", selection: Binding(
                        get: { userPreferences.dueSoonReminderLeadHours },
                        set: { userPreferences.dueSoonReminderLeadHours = $0 }
                    )) {
                        ForEach(Self.leadHourOptions, id: \.self) { hours in
                            Text(Self.leadHourLabel(hours)).tag(hours)
                        }
                    }

                    Toggle("Daily Review Digest", isOn: Binding(
                        get: { userPreferences.dailyDigestEnabled },
                        set: { userPreferences.dailyDigestEnabled = $0 }
                    ))

                    if userPreferences.dailyDigestEnabled {
                        Picker("Digest Time", selection: Binding(
                            get: { userPreferences.dailyDigestHour },
                            set: { userPreferences.dailyDigestHour = $0 }
                        )) {
                            ForEach(Self.hourOptions, id: \.self) { hour in
                                Text(Self.hourLabel(hour)).tag(hour)
                            }
                        }
                    }

                    Toggle("Post-Exam Reflection Nudge", isOn: Binding(
                        get: { userPreferences.examReflectionNudgeEnabled },
                        set: { userPreferences.examReflectionNudgeEnabled = $0 }
                    ))
                }
            } header: {
                ListSectionHeaderLabel(title: "Notifications", icon: "bell.fill", tint: .red)
            } footer: {
                Text("Due-soon reminders cover Assignments, Exams, and Readings. The reflection nudge asks how an exam went once its date passes.")
            }

            Section {
                Toggle("Sync Assignments to Reminders", isOn: Binding(
                    get: { userPreferences.remindersSyncEnabled },
                    set: { newValue in
                        userPreferences.remindersSyncEnabled = newValue
                        if newValue {
                            Task { _ = await calendarSyncService.requestReminderAccess() }
                        }
                    }
                ))

                Toggle("Push Deadlines to Calendar", isOn: Binding(
                    get: { userPreferences.calendarPushEnabled },
                    set: { newValue in
                        userPreferences.calendarPushEnabled = newValue
                        if newValue {
                            Task { _ = await calendarSyncService.requestEventAccess() }
                        }
                    }
                ))
            } header: {
                ListSectionHeaderLabel(title: "Calendar & Reminders", icon: "calendar.badge.clock", tint: .indigo)
            } footer: {
                Text("Assignments push to a \"StudyHub\" Reminders list, with completion synced back. Assignments and Exams push to a \"StudyHub Deadlines\" calendar. Importing Lectures from your own calendar is set up in the Lectures section above.")
            }

            Section {
                LabeledContent("Version", value: appVersionText)
            } header: {
                ListSectionHeaderLabel(title: "About", icon: "info.circle.fill", tint: .gray)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            hasCalendarAccess = calendarSyncService.hasEventAccess()
            if hasCalendarAccess {
                availableCalendars = calendarSyncService.availableEventCalendars()
            }
        }
    }

    private static let lectureDurationOptions = [30, 45, 60, 75, 90, 105, 120]
    private static let leadHourOptions = [1, 3, 6, 12, 24, 48, 72]
    private static let hourOptions = Array(0...23)

    private static func leadHourLabel(_ hours: Int) -> String {
        hours < 24 ? "\(hours) hour\(hours == 1 ? "" : "s") before" : "\(hours / 24) day\(hours / 24 == 1 ? "" : "s") before"
    }

    private static func hourLabel(_ hour: Int) -> String {
        var components = DateComponents()
        components.hour = hour
        let date = Calendar.current.date(from: components) ?? .now
        return date.formatted(date: .omitted, time: .shortened)
    }

    private var appVersionText: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "—"
        return "\(version) (\(build))"
    }
}
