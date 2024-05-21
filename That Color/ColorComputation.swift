//
//  ColorComputation.swift
//  That Color
//
//  Created by Paul Wong on 5/20/24.
//

import Foundation
import SwiftUI
import Combine
import Accelerate

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
    @Published var sortedColors: [(Double, Double, Double)] = []
    private var colors: [(Double, Double, Double)] = []
    private var currentBatchIndex = 0
    private let batchSize = 1000
    private let totalColors = 64 * 64 * 64
    private let accumulator = SortedColorsAccumulator()

    init() {
        generateColors()
    }

    func generateColors() {
        for red in 0..<64 {
            for green in 0..<64 {
                for blue in 0..<64 {
                    colors.append((Double(red) / 63.0, Double(green) / 63.0, Double(blue) / 63.0))
                }
            }
        }
    }

    func rgbToXyz(_ colors: [(Double, Double, Double)]) -> [(Double, Double, Double)] {
        let srgbToXyzMatrix: [Double] = [
            0.4124564, 0.3575761, 0.1804375,
            0.2126729, 0.7151522, 0.0721750,
            0.0193339, 0.1191920, 0.9503041
        ]

        return colors.map { color in
            let r = color.0 > 0.04045 ? pow((color.0 + 0.055) / 1.055, 2.4) : color.0 / 12.92
            let g = color.1 > 0.04045 ? pow((color.1 + 0.055) / 1.055, 2.4) : color.1 / 12.92
            let b = color.2 > 0.04045 ? pow((color.2 + 0.055) / 1.055, 2.4) : color.2 / 12.92

            let x = srgbToXyzMatrix[0] * r + srgbToXyzMatrix[1] * g + srgbToXyzMatrix[2] * b
            let y = srgbToXyzMatrix[3] * r + srgbToXyzMatrix[4] * g + srgbToXyzMatrix[5] * b
            let z = srgbToXyzMatrix[6] * r + srgbToXyzMatrix[7] * g + srgbToXyzMatrix[8] * b

            return (x, y, z)
        }
    }

    func xyzToLab(_ colors: [(Double, Double, Double)]) -> [(Double, Double, Double)] {
        let epsilon = 0.008856
        let kappa = 903.3

        let whiteReference = (0.95047, 1.00000, 1.08883)

        return colors.map { color in
            var x = color.0 / whiteReference.0
            var y = color.1 / whiteReference.1
            var z = color.2 / whiteReference.2

            x = x > epsilon ? pow(x, 1.0 / 3.0) : (kappa * x + 16) / 116
            y = y > epsilon ? pow(y, 1.0 / 3.0) : (kappa * y + 16) / 116
            z = z > epsilon ? pow(z, 1.0 / 3.0) : (kappa * z + 16) / 116

            let l = 116 * y - 16
            let a = 500 * (x - y)
            let b = 200 * (y - z)

            return (l, a, b)
        }
    }

    func labToXyz(_ colors: [(Double, Double, Double)]) -> [(Double, Double, Double)] {
        let epsilon = 0.008856
        let kappa = 903.3

        let whiteReference = (0.95047, 1.00000, 1.08883)

        return colors.map { color in
            let fy = (color.0 + 16) / 116
            let fx = color.1 / 500 + fy
            let fz = fy - color.2 / 200

            let fx3 = pow(fx, 3)
            let fy3 = pow(fy, 3)
            let fz3 = pow(fz, 3)

            let xr = fx3 > epsilon ? fx3 : (116 * fx - 16) / kappa
            let yr = color.0 > kappa * epsilon ? fy3 : color.0 / kappa
            let zr = fz3 > epsilon ? fz3 : (116 * fz - 16) / kappa

            let x = xr * whiteReference.0
            let y = yr * whiteReference.1
            let z = zr * whiteReference.2

            return (x, y, z)
        }
    }

    func xyzToRgb(_ colors: [(Double, Double, Double)]) -> [(Double, Double, Double)] {
        let xyzToSrgbMatrix: [Double] = [
            3.2404542, -1.5371385, -0.4985314,
            -0.9692660, 1.8760108, 0.0415560,
            0.0556434, -0.2040259, 1.0572252
        ]

        return colors.map { color in
            let x = color.0
            let y = color.1
            let z = color.2

            var r = xyzToSrgbMatrix[0] * x + xyzToSrgbMatrix[1] * y + xyzToSrgbMatrix[2] * z
            var g = xyzToSrgbMatrix[3] * x + xyzToSrgbMatrix[4] * y + xyzToSrgbMatrix[5] * z
            var b = xyzToSrgbMatrix[6] * x + xyzToSrgbMatrix[7] * y + xyzToSrgbMatrix[8] * z

            r = r > 0.0031308 ? 1.055 * pow(r, 1.0 / 2.4) - 0.055 : 12.92 * r
            g = g > 0.0031308 ? 1.055 * pow(g, 1.0 / 2.4) - 0.055 : 12.92 * g
            b = b > 0.0031308 ? 1.055 * pow(b, 1.0 / 2.4) - 0.055 : 12.92 * b

            return (r, g, b)
        }
    }

    func rgbToLab(_ colors: [(Double, Double, Double)]) -> [(Double, Double, Double)] {
        let xyzColors = rgbToXyz(colors)
        return xyzToLab(xyzColors)
    }

    func labToRgb(_ colors: [(Double, Double, Double)]) -> [(Double, Double, Double)] {
        let xyzColors = labToXyz(colors)
        return xyzToRgb(xyzColors)
    }

    func distance(_ color1: (Double, Double, Double), _ color2: (Double, Double, Double)) -> Double {
        return sqrt(pow(color1.0 - color2.0, 2) + pow(color1.1 - color2.1, 2) + pow(color1.2 - color2.2, 2))
    }

    func sortByLightness(_ colors: [(Double, Double, Double)]) -> [(Double, Double, Double)] {
        return colors.sorted { (color1, color2) -> Bool in
            let lightness1 = 0.299 * color1.0 + 0.587 * color1.1 + 0.114 * color1.2
            let lightness2 = 0.299 * color2.0 + 0.587 * color2.1 + 0.114 * color2.2
            return lightness1 < lightness2
        }
    }

    func tspNearestNeighbor(colors: [(Double, Double, Double)]) -> [(Double, Double, Double)] {
        var visited = Array(repeating: false, count: colors.count)
        var path = [(Double, Double, Double)]()
        var currentIndex = 0

        for _ in 0..<colors.count {
            visited[currentIndex] = true
            path.append(colors[currentIndex])
            var nearestDistance = Double.infinity
            var nearestIndex = -1

            for i in 0..<colors.count {
                if !visited[i] {
                    let dist = distance(colors[currentIndex], colors[i])
                    if dist < nearestDistance {
                        nearestDistance = dist
                        nearestIndex = i
                    }
                }
            }

            if nearestIndex != -1 {
                currentIndex = nearestIndex
            }
        }

        return path
    }

    func hierarchicalSort(colors: [(Double, Double, Double)]) -> [(Double, Double, Double)] {
        let batchSize = 100
        var sortedColors = [(Double, Double, Double)]()

        for start in stride(from: 0, to: colors.count, by: batchSize) {
            let end = min(start + batchSize, colors.count)
            let batch = Array(colors[start..<end])
            let sortedBatch = tspNearestNeighbor(colors: sortByLightness(batch))
            sortedColors.append(contentsOf: sortedBatch)
        }

        return tspNearestNeighbor(colors: sortedColors)
    }

    func computeNextBatch() {
        Task {
            let start = currentBatchIndex * batchSize
            let end = min(start + batchSize, totalColors)
            guard start < end else { return }
            let batch = Array(colors[start..<end])

            let sortedBatch = await Task.detached(priority: .userInitiated) {
                let labBatch = self.rgbToLab(batch)
                let sortedLabBatch = self.hierarchicalSort(colors: labBatch)
                return self.labToRgb(sortedLabBatch)
            }.value

            await accumulator.append(contentsOf: sortedBatch)

            let updatedSortedColors = await accumulator.getSortedColors()

            DispatchQueue.main.async {
                self.sortedColors = updatedSortedColors
            }

            currentBatchIndex += 1
        }
    }
}
