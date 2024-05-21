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
        VStack(spacing: 5) {
            ForEach(Array(colors.enumerated()), id: \.offset) { index, color in
                color
                    .cornerRadius(9)
                    .overlay(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .strokeBorder(.black.opacity(0.13), lineWidth: 3)

                    )
                    .animation(.smooth(duration: 0.3), value: color)
            }

            BottomControls()
                .padding(.vertical, 30)
        }
        .padding([.top, .horizontal])
        .background(Color.mainBackground)
    }
}
