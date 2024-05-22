//
//  ColorComputation.swift
//  That Color
//
//  Created by Paul Wong on 5/20/24.
//

import Foundation
import SwiftUI
import Combine

actor SortedColorsAccumulator {
    private var accumulatedSortedColors: [(Double, Double, Double)] = []

    func append(contentsOf newColors: [(Double, Double, Double)]) {
        accumulatedSortedColors.append(contentsOf: newColors)
    }

    func getSortedColors() -> [(Double, Double, Double)] {
        return accumulatedSortedColors
    }
}

class ColorComputation: ObservableObject {
    @Published var sortedColors: [[(Double, Double, Double)]] = Array(repeating: [], count: 6)
    private var colors: [[(Double, Double, Double)]] = Array(repeating: [], count: 6)
    private var currentBatchIndex = Array(repeating: 0, count: 6)
    private let batchSize = 1000
    private let totalColors = 64 * 64 * 64
    private let accumulator = Array(repeating: SortedColorsAccumulator(), count: 6)

    init() {
        generateColors()
    }

    func generateColors() {
        let hueStep = 1.0 / 6.0
        for red in 0..<64 {
            for green in 0..<64 {
                for blue in 0..<64 {
                    let color = (Double(red) / 63.0, Double(green) / 63.0, Double(blue) / 63.0)
                    let (hue, saturation, brightness) = getHSB(color: color)
                    let segment = Int(hue / hueStep)
                    if segment < 6 { // Ensuring we only have six segments
                        colors[segment].append(color)
                    }
                }
            }
        }

        // Sort each segment by saturation and brightness
        for i in 0..<6 {
            colors[i].sort { (color1, color2) -> Bool in
                let hsb1 = getHSB(color: color1)
                let hsb2 = getHSB(color: color2)
                if hsb1.1 == hsb2.1 {
                    return hsb1.2 < hsb2.2
                }
                return hsb1.1 < hsb2.1
            }
        }
    }

    func getHSB(color: (Double, Double, Double)) -> (Double, Double, Double) {
        let r = color.0
        let g = color.1
        let b = color.2
        let maxVal = max(r, g, b)
        let minVal = min(r, g, b)
        let delta = maxVal - minVal

        var hue: Double = 0
        let saturation: Double = maxVal == 0 ? 0 : delta / maxVal
        let brightness: Double = maxVal

        if delta != 0 {
            if maxVal == r {
                hue = (g - b) / delta + (g < b ? 6 : 0)
            } else if maxVal == g {
                hue = (b - r) / delta + 2
            } else {
                hue = (r - g) / delta + 4
            }
            hue /= 6
        }

        return (hue, saturation, brightness)
    }

    func computeNextBatch(segment: Int) {
        Task {
            let start = currentBatchIndex[segment] * batchSize
            let end = min(start + batchSize, colors[segment].count)
            guard start < end else { return }
            let batch = Array(colors[segment][start..<end])

            await accumulator[segment].append(contentsOf: batch)

            let updatedSortedColors = await accumulator[segment].getSortedColors()

            DispatchQueue.main.async {
                self.sortedColors[segment] = updatedSortedColors
            }

            currentBatchIndex[segment] += 1
        }
    }
}
