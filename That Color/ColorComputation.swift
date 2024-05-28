//
//  ColorComputation.swift
//  That Color
//
//  Created by Paul Wong on 5/20/24.
//

import SwiftUI
import Combine

class ColorComputation: ObservableObject {
    @Published var sortedColors: [[(Double, Double, Double)]] = Array(repeating: [], count: 8)

    private let colorSpaceSize = 64
    private let segments = 8 // Red, Orange, Yellow, Green, Teal, Blue, Indigo, Purple
    private let batchSize = 500

    private let hueRanges: [(Double, Double)] = [
        (0.0, 0.03),     // Red
        (0.03, 0.1),     // Orange
        (0.1, 0.17),     // Yellow
        (0.17, 0.3),     // Green
        (0.3, 0.4),      // Teal
        (0.4, 0.55),     // Blue
        (0.55, 0.65),    // Indigo
        (0.65, 0.8),     // Purple
        (0.8, 1.0)       // Red continuation
    ]

    init() {
        computeColors()
    }

    func computeColors() {
        DispatchQueue.global(qos: .userInitiated).async {
            var allColors = [(Double, Double, Double)]()

            // Generate colors in 64x64x64 color space
            for r in 0..<self.colorSpaceSize {
                for g in 0..<self.colorSpaceSize {
                    for b in 0..<self.colorSpaceSize {
                        let color = (Double(r) / Double(self.colorSpaceSize - 1),
                                     Double(g) / Double(self.colorSpaceSize - 1),
                                     Double(b) / Double(self.colorSpaceSize - 1))
                        if self.isValidColor(color: color) {
                            allColors.append(color)
                        }
                    }
                }
            }

            // Sort colors into hue categories concurrently
            let group = DispatchGroup()
            var segmentColorsArray = [[(Double, Double, Double)]](repeating: [], count: self.segments)

            for segment in 0..<self.segments {
                group.enter()
                DispatchQueue.global(qos: .userInitiated).async {
                    let hueRange = self.hueRanges[segment]
                    var segmentColors = allColors.filter { color in
                        let hue = UIColor(red: color.0, green: color.1, blue: color.2, alpha: 1).hsb.hue
                        return hue >= hueRange.0 && hue < hueRange.1
                    }

                    // Sort by saturation and brightness before TSP
                    segmentColors.sort {
                        let hsb1 = UIColor(red: $0.0, green: $0.1, blue: $0.2, alpha: 1).hsb
                        let hsb2 = UIColor(red: $1.0, green: $1.1, blue: $1.2, alpha: 1).hsb
                        if hsb1.saturation != hsb2.saturation {
                            return hsb1.saturation > hsb2.saturation
                        } else {
                            return hsb1.brightness > hsb2.brightness
                        }
                    }

                    segmentColors = self.batchProcessColors(colors: segmentColors)
                    segmentColorsArray[segment] = segmentColors
                    group.leave()
                }
            }

            group.notify(queue: .main) {
                self.sortedColors = segmentColorsArray
            }
        }
    }

    private func isValidColor(color: (Double, Double, Double)) -> Bool {
        let hsb = UIColor(red: color.0, green: color.1, blue: color.2, alpha: 1).hsb
        return hsb.saturation > 0.5 && hsb.brightness > 0.5 // Adjusted for more vibrant and lighter colors
    }

    private func colorDistance(_ color1: (Double, Double, Double), _ color2: (Double, Double, Double)) -> Double {
        let rDiff = color1.0 - color2.0
        let gDiff = color1.1 - color2.1
        let bDiff = color1.2 - color2.2
        return sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff)
    }

    private func batchProcessColors(colors: [(Double, Double, Double)]) -> [(Double, Double, Double)] {
        let batches = stride(from: 0, to: colors.count, by: batchSize).map {
            Array(colors[$0..<min($0 + batchSize, colors.count)])
        }

        var sortedColors = [(Double, Double, Double)]()
        var currentBatch = batches.first ?? []

        for _ in 0..<batches.count {
            currentBatch = tspSort(colors: currentBatch)
            sortedColors.append(contentsOf: currentBatch)

            if let nextBatch = batches.dropFirst().first {
                currentBatch = nextBatch
            } else {
                break
            }
        }

        return sortedColors
    }

    private func tspSort(colors: [(Double, Double, Double)]) -> [(Double, Double, Double)] {
        guard !colors.isEmpty else { return [] }

        var path = [colors[0]]
        var remainingColors = Array(colors.dropFirst())

        while !remainingColors.isEmpty {
            let lastColor = path.last!
            let closestColorIndex = remainingColors.indices.min(by: { colorDistance(lastColor, remainingColors[$0]) < colorDistance(lastColor, remainingColors[$1]) })!
            path.append(remainingColors[closestColorIndex])
            remainingColors.remove(at: closestColorIndex)
        }

        return path
    }

    func computeNextBatch(segment: Int) {
        // Logic to fetch more colors for a specific segment if needed
    }
}

extension UIColor {
    var hsb: (hue: Double, saturation: Double, brightness: Double) {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)

        return (Double(hue), Double(saturation), Double(brightness))
    }
}
