//
//  MetalBackground.swift
//  ONE
//
//  Created by Michael Fleps on 29.05.25.
//


import SwiftUI

struct MetalBackground: View {
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            Color.black.opacity(0.3)
                .blur(radius: 60)
                .ignoresSafeArea()
        }
    }
}

#Preview {
    MetalBackground()
}
