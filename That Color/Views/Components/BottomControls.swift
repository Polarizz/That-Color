//
//  BottomControls.swift
//  That Color
//
//  Created by Paul Wong on 5/20/24.
//

import SwiftUI
//import PolyKit

struct BottomControls: View {
    var body: some View {
        HStack(spacing: 0) {
            Spacer()

            Circle()
                .fill(.primaryLabel)
                .frame(width: 80, height: 80)
                .shadow(color: .black.opacity(0.13), radius: 1, x: 10, y: 10)

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
    }
}
