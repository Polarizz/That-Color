//
//  ContentView.swift
//  That Color
//
//  Created by Paul Wong on 5/16/24.
//

import SwiftUI

class GridConfig: ObservableObject {
    @Published var rowCount: Int = 4 {
        didSet {
            updateColorCount()
        }
    }
    @Published var columnCount: Int = 1 {
        didSet {
            updateColorCount()
        }
    }
    @Published var colorCount: Int = 4

    private func updateColorCount() {
        colorCount = rowCount * columnCount
    }
}

struct ContentView: View {
    @StateObject private var gridConfig = GridConfig()
    @State private var paletteColors: [Color] = []
    @State private var selectedItem: String = "1×4"

    var body: some View {
        ZStack {
            CameraView(paletteColors: $paletteColors, colorCount: gridConfig.colorCount)
                .edgesIgnoringSafeArea(.all)

            PaletteView(colors: paletteColors, selectedItem: $selectedItem)
                .environmentObject(gridConfig)
        }
        .onAppear {
            paletteColors = Array(repeating: .clear, count: gridConfig.colorCount)
        }
        .onChange(of: gridConfig.colorCount) { newValue in
            paletteColors = Array(repeating: .clear, count: newValue)
        }
    }
}
