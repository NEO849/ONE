//
//  DismissKeyboardOnTapModifier.swift
//  ONE
//
//  Created by Michael Fleps on 08.11.25.
//

import SwiftUI

/// Globaler Modifier zum Schließen der Tastatur, wenn außerhalb getippt wird.
/// Funktioniert mit jedem View, das @FocusState  nutzt.
struct DismissKeyboardOnTapModifier: ViewModifier {
    var isFocused: FocusState<Bool>.Binding

    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle()) // Macht den gesamten Bereich „tappbar“
            .onTapGesture {
                isFocused.wrappedValue = false // Fokus entfernen = Tastatur schließen
            }
    }
}

extension View {
    /// Erlaubt `.keyboardDismissable($isInputFocused)` in jeder View
    func keyboardDismissable(_ isFocused: FocusState<Bool>.Binding) -> some View {
        self.modifier(DismissKeyboardOnTapModifier(isFocused: isFocused))
    }
}
