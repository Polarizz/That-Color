//
//  ContentView.swift
//  That Color
//
//  Created by Paul Wong on 5/16/24.
//

import SwiftUI

class GridConfig: ObservableObject {
    @Published var rowCount: Int = 4
    @Published var columnCount: Int = 1
}

struct ContentView: View {
    @StateObject private var gridConfig = GridConfig()
    @State private var paletteColors: [Color] = Array(repeating: .clear, count: 24)
    @State private var selectedItem: String = "1×4"

    var body: some View {
        ZStack {
            CameraView(paletteColors: $paletteColors, colorCount: gridConfig.rowCount * gridConfig.columnCount)
                .edgesIgnoringSafeArea(.all)

            PaletteView(colors: paletteColors, selectedItem: $selectedItem)
                .environmentObject(gridConfig)
        }
    }
}
