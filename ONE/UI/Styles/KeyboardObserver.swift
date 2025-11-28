import SwiftUI
import Combine

/// Beobachtet das Keyboard und veröffentlicht eine korrigierte Höhe sowie die Animationsdauer.
final class KeyboardObserver: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    @Published var animationDuration: Double = 0.25

    private var cancellables = Set<AnyCancellable>()

    func startObserving() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notif in
                self?.handleShow(notification: notif)
            }
            .store(in: &cancellables)

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] notif in
                self?.handleHide(notification: notif)
            }
            .store(in: &cancellables)
    }

    private func handleShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        let keyboardHeight = keyboardFrame.height
        
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: duration)) {
                self.keyboardHeight = keyboardHeight
                self.animationDuration = duration
            }
        }
    }

    private func handleHide(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
        
        DispatchQueue.main.async {
            withAnimation(.easeOut(duration: duration)) {
                self.keyboardHeight = 0
                self.animationDuration = duration
            }
        }
    }

    func stopObserving() {
        cancellables.forEach { $0.cancel() }
        cancellables.removeAll()
    }
}
