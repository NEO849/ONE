//
//  SplashView.swift
//  ONE
//
//  Created by Michael Fleps on 29.05.25.
//

import SwiftUI
import AVFoundation

/// Haupt-SplashView mit animiertem Übergang zur MainView
struct SplashView: View {
    
    @State private var isActive = false
    @State private var player: AVAudioPlayer?
    
    var body: some View {
        ZStack {
            MetalBackground()
            Image("onetext")
                .resizable()
                .frame(width: 300, height: 300)
            
        }
        // 🧊 Übergang zur MainView
        .onAppear {
            playSound()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.5) {
                withAnimation {
                    isActive = true
                }
            }
        }
        .fullScreenCover(isPresented: $isActive) {
            MainView()
        }
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "onesplash", withExtension: "mp3") else {
            print("❌ Sounddatei nicht gefunden")
            return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch {
            print("❌ Fehler beim Abspielen: \(error.localizedDescription)")
        }
    }
}

#Preview {
    SplashView()
}
