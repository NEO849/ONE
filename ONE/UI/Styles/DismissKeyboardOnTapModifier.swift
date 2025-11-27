//
//  DismissKeyboardOnTapModifier.swift
//  ONE
//
//  Created by Michael Fleps on 08.11.25.
//

import SwiftUI

/// Tastatur schließen beim Tippen – ohne Gesten/Buttons zu blockieren.
struct DismissKeyboardOnTapModifier: ViewModifier {
    var isFocused: FocusState<Bool>.Binding                                           // Fokus-Binding der View
    
    func body(content: Content) -> some View {
        content
            .contentShape(Rectangle())                                                // leerer Bereich wird tappbar
            .simultaneousGesture(                                                     // ✅ stört keine anderen Gesten
                TapGesture().onEnded {
                    isFocused.wrappedValue = false                                    // Fokus weg -> Tastatur zu
                }
            )
    }
}

extension View {
    /// Einheitliche API für alle Screens.
    func keyboardDismissable(_ isFocused: FocusState<Bool>.Binding) -> some View {
        modifier(DismissKeyboardOnTapModifier(isFocused: isFocused))                  // Modifier anwenden
    }
}
