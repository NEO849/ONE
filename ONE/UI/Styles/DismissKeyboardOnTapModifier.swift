//
//  DismissKeyboardOnTapModifier.swift
//  ONE
//
//  Created by Michael Fleps on 08.11.25.
//

import SwiftUI

/// Dismiss-Modifier für alle Views – schließt Tastatur bei Tap außerhalb – funktioniert mit @FocusState
struct DismissKeyboardOnTapModifier: ViewModifier {
    var isFocused: FocusState<Bool>.Binding

    func body(content: Content) -> some View {
        content
            .gesture(
                TapGesture()
                    .onEnded {
                        isFocused.wrappedValue = false
                    }
            )
    }
}

extension View {
    /// Erlaubt ".keyboardDismissable($isInputFocused)" auch mit "@FocusState"
    func keyboardDismissable(_ isFocused: FocusState<Bool>.Binding) -> some View {
        self.modifier(DismissKeyboardOnTapModifier(isFocused: isFocused))
    }
}
