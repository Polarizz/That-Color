//
//  PalatteView.swift
//  That Color
//
//  Created by Paul Wong on 5/16/24.
//

import SwiftUI

struct PaletteView: View {
    var colors: [Color]

    var body: some View {
        VStack(spacing: 3) {
            ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                color
                    .cornerRadius(9)
                    .animation(.smooth(duration: 0.3), value: color)
            }
        }
        .padding()
        .background(Color.white)
    }
}
