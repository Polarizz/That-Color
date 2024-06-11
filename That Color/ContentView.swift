//
//  ContentView.swift
//  That Color
//
//  Created by Paul Wong on 5/16/24.
//

import SwiftUI

class GridConfig: ObservableObject {
    @Published var rowCount: Int = 3 {
        didSet {
            updateColorCount()
        }
    }
    @Published var columnCount: Int = 1 {
        didSet {
            updateColorCount()
        }
    }
    @Published var colorCount: Int = 3

    private func updateColorCount() {
        colorCount = rowCount * columnCount
    }
}

struct ContentView: View {
    @StateObject private var gridConfig = GridConfig()
    @State private var paletteColors: [Color] = []
    @State private var selectedItem: String = "3 COLORS"

    var body: some View {
        ZStack {
            CameraView(paletteColors: $paletteColors, colorCount: gridConfig.colorCount)
                .edgesIgnoringSafeArea(.all)

            NavigationStack {
                PaletteView(colors: paletteColors, selectedItem: $selectedItem)
                    .environmentObject(gridConfig)
            }
        }
        .onAppear {
            paletteColors = Array(repeating: .clear, count: gridConfig.colorCount)
        }
        .onChange(of: gridConfig.colorCount) { newValue, _ in
//            paletteColors = Array(repeating: .clear, count: newValue)
            Haptics.shared.play(.light, customIntensity: 0.7)
        }
    }
}
