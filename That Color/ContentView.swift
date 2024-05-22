//
//  ContentView.swift
//  That Color
//
//  Created by Paul Wong on 5/16/24.
//

import SwiftUI

enum BlurType: String, CaseIterable {
    case clipped = "Clipped"
    case freeStyle = "Free Style"
}

struct ContentView: View {
    @State private var blurType: BlurType = .freeStyle

    @State private var paletteColors: [Color] = Array(repeating: .clear, count: 6)

    @State private var start = 0.0

    /// The start position of the variable blur, from 0 (top) to 1 (bottom).
    @State private var end = 1.0

    /// The blur radius.
    @State private var radius = 10.0

    /// The maximum number of samples to use for the blur.
    @State private var maxSamples = 15.0

    var body: some View {
//        ZStack {
//            CameraView(paletteColors: $paletteColors)
//                .edgesIgnoringSafeArea(.all)
//
//            PaletteView(colors: paletteColors)
//        }

        GridView()
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.mainBackground.opacity(0.0), Color.mainBackground.opacity(0.6)]),
                    startPoint: .bottom,
                    endPoint: .top
                )
                .frame(height: 320)
                .padding([.horizontal, .top], -40)
                .allowsHitTesting(false)
                .ignoresSafeArea()
                , alignment: .top
            )
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.mainBackground.opacity(0.0), Color.mainBackground.opacity(0.6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 390)
                .padding([.horizontal, .bottom], -40)
                .allowsHitTesting(false)
                .ignoresSafeArea()
                , alignment: .bottom
            )
            .overlay(
                Text("79%")
                    .font(.custom("BNHightideRegular", size: 70))
                    .foregroundStyle(.primaryLabel)
                    .shadow(color: .black.opacity(0.19), radius: 1, x: 10, y: 10)
                    .padding()
                , alignment: .top
            )
            .overlay(
                HStack(spacing: 0) {
                    Spacer()

                    Circle()
                        .fill(.primaryLabel)
                        .frame(width: 80, height: 80)
                        .shadow(color: .black.opacity(0.19), radius: 1, x: 10, y: 10)

                    Spacer()
                }
                .overlay(
                    Polygon(count: 3, relativeCornerRadius: 0.5)
                        .fill(.regularMaterial)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(30))
                        .brightness(-0.1)
                    , alignment: .leading
                )
                .padding(.top, 10)
                .padding(.horizontal)
                .padding(.vertical, 30)
                .padding()
                , alignment: .bottom
            )
    }
}
