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

    @StateObject private var colorComputation = ColorComputation()

    var body: some View {
//        ZStack {
//            CameraView(paletteColors: $paletteColors)
//                .edgesIgnoringSafeArea(.all)
//
//            PaletteView(colors: paletteColors)
//        }

        TabView {
            ForEach(0..<6, id: \.self) { segment in
                GridView(colorComputation: colorComputation, segment: segment)
                    .tabItem {
                        Text("Segment \(segment + 1)")
                    }
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .ignoresSafeArea()
    }
}
