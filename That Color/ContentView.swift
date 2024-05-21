//
//  ContentView.swift
//  That Color
//
//  Created by Paul Wong on 5/16/24.
//

import SwiftUI

struct ContentView: View {

    @State private var paletteColors: [Color] = Array(repeating: .clear, count: 6)

    var body: some View {
//        ZStack {
//            CameraView(paletteColors: $paletteColors)
//                .edgesIgnoringSafeArea(.all)
//
//            PaletteView(colors: paletteColors)
//        }

        GridView()
    }
}
