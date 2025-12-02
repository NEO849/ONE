//
//  ChatMessageListView.swift
//  ONE
//
//  Created by Michael Fleps on 27.11.25.
//

import SwiftUI

/// Reine Chatliste:
/// - kümmert sich NUR um ScrollView + Auto-Scroll
/// - kennt keine Services, kein ViewModel
struct ChatMessageListView: View {

    let steps: [ChatStep]                                                                              // Daten rein
    let isInputFocused: Bool                                                                           // Fokus rein
    let bottomScrollTriggerValue: Int                                                                  // Trigger (z. B. count)

    private let bottomAnchorIdentifier: String = "bottomAnchorIdentifier"                              // Stabiler Scroll-Anker

    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(showsIndicators: false) {
                LazyVStack(alignment: .leading) {
                    ForEach(steps, id: \.id) { stepValue in
                        VStack() {
                            UserPromptBubbleView(promptText: stepValue.userPrompt)
                            StackedAgentCardsView(step: stepValue)
                        }
                    }

                    Color.clear
                        .frame(height: 22)
                        .id(bottomAnchorIdentifier)
                }
                .frame(maxWidth: .infinity)                                       // EINMAL reicht
                .padding(.top, 6)
            }
         //   .scrollDismissesKeyboard(.immediately)

            .onChange(of: bottomScrollTriggerValue) { _ in
                scrollToBottom(scrollProxy: scrollProxy)
            }

            .onChange(of: isInputFocused) { _ in
                DispatchQueue.main.async {
                    scrollToBottom(scrollProxy: scrollProxy)
                }
            }
        }
    }

    private func scrollToBottom(scrollProxy: ScrollViewProxy) {
        withAnimation(.easeInOut) {
            scrollProxy.scrollTo(bottomAnchorIdentifier, anchor: .bottom)
        }
    }
}

#Preview("ChatMessageListView – Beispiel") {
    
    // ✅ Beispiel-Daten werden direkt hier erzeugt, ohne ViewModel/Service                   // Preview soll unabhängig bleiben
    let beispielSteps: [ChatStep] = ChatMessageListViewPreviewFactory
        .erstelleBeispielSteps()                                                            // leicht lesbarer Builder
    
    return ChatMessageListView(
        steps: beispielSteps,                                                               // ChatSteps in die Liste geben
        isInputFocused: false,                                                              // in Preview meist NICHT fokussiert
        bottomScrollTriggerValue: beispielSteps.count                                       // Trigger = Anzahl Steps (wie in App)
    )
    .background(Color.black.opacity(0.001))                                                 // verhindert „transparentes Preview-Flackern“
}

// MARK: - Preview Factory (nur für #Preview)
// Hinweis: Liegt im selben File, stört den Produktivcode nicht und bleibt extrem simpel.
private enum ChatMessageListViewPreviewFactory {
    
    static func erstelleBeispielSteps() -> [ChatStep] {
        var ergebnisSteps: [ChatStep] = []                                                  // Array für mehrere Steps
        
        // Step 1
        var ersterStep = ChatStep(userPrompt: "Erkläre MVVM in SwiftUI ganz kurz.")
        ersterStep.setAgentReply(agent: .gemini, text: "MVVM trennt View (UI) von Logik (ViewModel) und Datenzugriff (Repository).")
        ersterStep.setAgentReply(agent: .mistral, text: "View zeigt State, ViewModel hält State und ruft Services/Repos auf.")
        ersterStep.setAgentReply(agent: .claude, text: "Durch Bindings bleibt die UI automatisch aktuell, weil das ViewModel publishen kann.")
        ersterStep.setFinalReply(text: "Kurz: View rendert, ViewModel steuert State/Logik, Repository kapselt Datenzugriff.")
        ergebnisSteps.append(ersterStep)
        
        // Step 2
        var zweiterStep = ChatStep(userPrompt: "Warum ScrollViewReader + Bottom-Anker?")
        zweiterStep.setAgentReply(agent: .gemini, text: "Damit du zuverlässig ans Ende scrollen kannst – ohne Timing-Probleme.")
        zweiterStep.setAgentReply(agent: .mistral, text: "Ein fester .id-Anker ist stabiler als 'last message id', wenn UI noch rendert.")
        zweiterStep.setAgentReply(agent: .claude, text: "Auto-Scroll ist so entkoppelt: Liste kennt kein ViewModel, nur Trigger-Werte.")
        ergebnisSteps.append(zweiterStep)
        
        // Step 3 (ohne FinalReply – damit du auch diesen Zustand in der UI siehst)
        var dritterStep = ChatStep(userPrompt: "Zeig mir ein Beispiel mit @State und @Binding.")
        dritterStep.setAgentReply(agent: .gemini, text: "@State gehört der View, @Binding ist eine Referenz auf State von außen.")
        ergebnisSteps.append(dritterStep)
        
        return ergebnisSteps                                                                 // fertiges Array zurückgeben
    }
}
