import SwiftUI
import UIKit

/// A compact, tappable date field that opens a floating Apple Calendar-style
/// graphical date picker (day/month/year drill-down is native to `.graphical`).
struct StudyHubDateField: View {
    let label: String
    @Binding var date: Date

    @State private var isPresented = false

    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.primary)
            Spacer()
            Button {
                isPresented = true
            } label: {
                Text(date.shortDateString)
                    .foregroundStyle(.secondary)
                    .frame(width: 110, alignment: .trailing)
            }
            .buttonStyle(.plain)
            .background(
                DirectionalPopoverAnchor(isPresented: $isPresented, arrowDirections: .left) {
                    DatePicker(label, selection: $date, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .frame(height: 360, alignment: .top)
                        .clipped()
                        .transaction { transaction in
                            transaction.animation = nil
                        }
                        .padding()
                        .frame(width: 340, height: 400, alignment: .top)
                }
            )
        }
        .contentShape(Rectangle())
    }
}

/// Presents SwiftUI content through a real `UIPopoverPresentationController` so the
/// arrow direction can be constrained via `permittedArrowDirections`. SwiftUI's native
/// `.popover(arrowEdge:)` only treats the edge as a hint and can silently flip sides
/// even when there is ample room on the preferred side, which is what this works around.
struct DirectionalPopoverAnchor<Content: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    let arrowDirections: UIPopoverArrowDirection
    @ViewBuilder let content: () -> Content

    func makeUIViewController(context: Context) -> UIViewController {
        UIViewController()
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        context.coordinator.isPresentedBinding = $isPresented
        context.coordinator.arrowDirections = arrowDirections
        context.coordinator.latestContent = content

        if isPresented {
            context.coordinator.show(from: uiViewController)
        } else {
            context.coordinator.hide()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(isPresented: $isPresented, arrowDirections: arrowDirections)
    }

    final class Coordinator: NSObject, UIPopoverPresentationControllerDelegate {
        var isPresentedBinding: Binding<Bool>
        var arrowDirections: UIPopoverArrowDirection
        var latestContent: (() -> Content)?

        /// Reused across every presentation for this field, rather than recreated per
        /// tap. The wrapped native calendar/wheel only needs to complete its first
        /// internal layout settle once per hosting controller instance — keeping the
        /// same instance alive means that settle, once done, stays done for every
        /// subsequent open, not just the current one.
        private var hosting: UIHostingController<Content>?
        private var isShown = false

        init(isPresented: Binding<Bool>, arrowDirections: UIPopoverArrowDirection) {
            self.isPresentedBinding = isPresented
            self.arrowDirections = arrowDirections
        }

        func show(from anchor: UIViewController) {
            guard !isShown, let latestContent else { return }

            let hostingController: UIHostingController<Content>
            if let existing = hosting {
                existing.rootView = latestContent()
                hostingController = existing
            } else {
                let created = UIHostingController(rootView: latestContent())
                created.modalPresentationStyle = .popover
                hosting = created
                hostingController = created
            }

            let size = hostingController.sizeThatFits(in: CGSize(width: 400, height: 500))
            hostingController.preferredContentSize = size
            hostingController.view.frame = CGRect(origin: .zero, size: size)

            // Pre-warm: attach to the real, window-connected view hierarchy first (hidden),
            // so the native calendar/wheel performs its first internal layout pass while
            // actually part of a live hierarchy — which is what it needs to fully commit to
            // our constrained, top-aligned frame — rather than settling visibly after the
            // popover is already on screen. The actual presentation is deferred to the next
            // run loop turn so that forced pass has a chance to land first.
            anchor.addChild(hostingController)
            anchor.view.addSubview(hostingController.view)
            hostingController.view.alpha = 0
            hostingController.didMove(toParent: anchor)
            hostingController.view.setNeedsLayout()
            hostingController.view.layoutIfNeeded()

            DispatchQueue.main.async { [weak self, weak anchor] in
                guard let self, let anchor else { return }

                hostingController.willMove(toParent: nil)
                hostingController.view.removeFromSuperview()
                hostingController.removeFromParent()
                hostingController.view.alpha = 1

                if let popover = hostingController.popoverPresentationController {
                    popover.sourceView = anchor.view
                    popover.sourceRect = anchor.view.bounds
                    popover.permittedArrowDirections = self.arrowDirections
                    popover.delegate = self
                }

                anchor.present(hostingController, animated: true)
                self.isShown = true
            }
        }

        func hide() {
            guard isShown else { return }
            hosting?.dismiss(animated: true)
            isShown = false
        }

        func popoverPresentationControllerDidDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) {
            isShown = false
            isPresentedBinding.wrappedValue = false
        }

        func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
            .none
        }
    }
}
