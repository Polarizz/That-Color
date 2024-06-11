//
//  MeshGradientView.swift
//  That Color
//
//  Created by Paul Wong on 6/10/24.
//

import SwiftUI

struct MeshGradientView: View {

    @State var t: Float = 0.0
    @State var timer: Timer?

    var colors: [Color]

    var body: some View {
        MeshGradient(
            width: 3,
            height: 3,
            points: [
                [0.0, 0.0],
                [0.5, 0.0],
                [1.0, 0.0],
                [sinInRange(-0.8...(-0.2), 0.439, 0.342, t), sinInRange(0.3...0.7, 3.42, 0.984, t)],
                [sinInRange(0.0...0.8, 0.239, 0.084, t), sinInRange(0.2...0.8, 5.21, 0.242, t)],
                [sinInRange(1.0...1.5, 0.939, 0.084, t), sinInRange(0.4...0.8, 0.25, 0.642, t)],
                [sinInRange(-0.8...0.0, 1.439, 0.442, t), sinInRange(1.4...1.9, 3.42, 0.984, t)],
                [sinInRange(0.3...0.7, 0.739, 0.784, t), sinInRange(1.1...1.2, 1.22, 0.772, t)],
                [sinInRange(1.0...1.5, 0.939, 0.056, t), sinInRange(1.3...1.7, 0.47, 0.342, t)]
            ],
            colors: colors
        )
        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.01, repeats: true) { _ in
                t += 0.02
            }
        }
    }

    func sinInRange(_ range: ClosedRange<Float>, _ offset: Float, _ timeScale: Float, _ t: Float) -> Float {
        let amplitude = (range.upperBound - range.lowerBound) / 2
        let midPoint = (range.upperBound + range.lowerBound) / 2
        return midPoint + amplitude * sin(timeScale * t + offset)
    }
}
