import Foundation

/// Preset focus-timer durations (Phase 4.3, requirement 3). `.custom` holds
/// whatever the user picked in the Custom stepper.
enum PomodoroDuration: Hashable, Identifiable {
    case twentyFive
    case fortyFive
    case sixty
    case ninety
    case custom(minutes: Int)

    var id: String {
        switch self {
        case .twentyFive: return "25"
        case .fortyFive: return "45"
        case .sixty: return "60"
        case .ninety: return "90"
        case .custom: return "custom"
        }
    }

    var minutes: Int {
        switch self {
        case .twentyFive: return 25
        case .fortyFive: return 45
        case .sixty: return 60
        case .ninety: return 90
        case .custom(let minutes): return minutes
        }
    }

    var label: String {
        switch self {
        case .twentyFive: return "25 min"
        case .fortyFive: return "45 min"
        case .sixty: return "60 min"
        case .ninety: return "90 min"
        case .custom: return "Custom"
        }
    }

    static let presets: [PomodoroDuration] = [.twentyFive, .fortyFive, .sixty, .ninety]
}

/// Plain countdown timer — Start/Pause/Resume/Finish, no notifications, no
/// scheduling (requirement 3: "Timer only"). `completedPomodoros` is the
/// only output `StudySessionViewModel` reads, stored into `StudySession`
/// at Session Summary time.
@MainActor
@Observable
final class PomodoroTimerModel {
    private(set) var selectedDuration: PomodoroDuration = .twentyFive
    private(set) var remainingSeconds: Int = PomodoroDuration.twentyFive.minutes * 60
    private(set) var isRunning = false
    private(set) var isPaused = false
    private(set) var completedPomodoros = 0

    private var timer: Timer?

    var totalSeconds: Int {
        selectedDuration.minutes * 60
    }

    var progress: Double {
        totalSeconds > 0 ? 1 - (Double(remainingSeconds) / Double(totalSeconds)) : 0
    }

    var timeText: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    /// Changing the duration while idle (not running/paused) resets the
    /// countdown to match; has no effect mid-run, so switching presets
    /// doesn't disrupt a timer already in progress.
    func selectDuration(_ duration: PomodoroDuration) {
        selectedDuration = duration
        guard !isRunning, !isPaused else { return }
        remainingSeconds = duration.minutes * 60
    }

    func start() {
        guard !isRunning else { return }
        if !isPaused {
            remainingSeconds = totalSeconds
        }
        isRunning = true
        isPaused = false
        scheduleTick()
    }

    func pause() {
        guard isRunning else { return }
        isRunning = false
        isPaused = true
        timer?.invalidate()
        timer = nil
    }

    func resume() {
        guard isPaused else { return }
        start()
    }

    /// Ends the current pomodoro early (manual "Finish") — still counts
    /// toward `completedPomodoros`, matching a real Pomodoro session ending
    /// on the student's own call rather than only on the clock reaching 0.
    func finish() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        completedPomodoros += 1
        remainingSeconds = totalSeconds
    }

    private func scheduleTick() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
    }

    private func tick() {
        guard isRunning else { return }
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        } else {
            finish()
        }
    }
}
