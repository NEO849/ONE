//
//  FullAnswerAgentSheet.swift
//  ONE
//
//  Created by Michael Fleps on 27.11.25.
//

import SwiftUI

/// Zeigt den vollständigen Inhalt eines Agenten in einem Sheet an.
struct FullAnswerAgentSheet: View {
    let agent: AgentType
    let fullResponse: String
    
    var body: some View {
        ZStack {
            Image(agent.theme.backgroundAssetName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
   
            // Inhalt
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Image("logo")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 32)
                    
                    Text(agent.displayName)
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    
                    Spacer()
                }
                .padding(.top, 40)
                
                // Antworttext (mit ScrollView, falls die Antwort sehr lang ist)
                ScrollView {
                    Text(fullResponse)
                        .font(.body)
                        .multilineTextAlignment(.leading)
                        .foregroundStyle(.white.opacity(0.95))
                }
                
            }
            .padding(.horizontal, 244)
        }
    }
}


#Preview {
    FullAnswerAgentSheet(
        agent: .gemini,
        fullResponse: "Dies ist eine sehr lange Beispielantwort, die den Text fließend darstellt. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur."
    )
}
