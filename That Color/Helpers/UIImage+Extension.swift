//
//  UIImage+Extension.swift
//  That Color
//
//  Created by Paul Wong on 5/16/24.
//

import UIKit

extension UIImage {
    func resized(to size: CGSize) -> UIImage? {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: format)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    func extractColors(colorCount: Int = 12, scaleSize: CGSize = CGSize(width: 64, height: 64)) -> [UIColor] {
        guard let resizedImage = self.resized(to: scaleSize), let cgImage = resizedImage.cgImage else { return [] }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let imageData = UnsafeMutablePointer<UInt8>.allocate(capacity: width * height * bytesPerPixel)
        defer { imageData.deallocate() }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: imageData,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerPixel * width,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return []
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        var pixels: [ColorBucket] = []
        pixels.reserveCapacity(width * height)
        for y in 0..<height {
            for x in 0..<width {
                let offset = (y * width + x) * bytesPerPixel
                let red = CGFloat(imageData[offset]) / 255.0
                let green = CGFloat(imageData[offset + 1]) / 255.0
                let blue = CGFloat(imageData[offset + 2]) / 255.0
                pixels.append(ColorBucket(red, green, blue))
            }
        }

        let colorBuckets = medianCut(pixels, bucketCount: colorCount)

        return colorBuckets.map { bucket in
            UIColor(red: bucket.average().x, green: bucket.average().y, blue: bucket.average().z, alpha: 1.0)
        }
    }
}

struct ColorBucket {
    var x: CGFloat
    var y: CGFloat
    var z: CGFloat

    init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }

    func average() -> ColorBucket {
        return self
    }
}

func medianCut(_ pixels: [ColorBucket], bucketCount: Int) -> [ColorBucket] {
    var buckets = [pixels]

    while buckets.count < bucketCount {
        var newBuckets: [[ColorBucket]] = []
        for bucket in buckets {
            let (first, second) = splitBucket(bucket)
            newBuckets.append(first)
            newBuckets.append(second)
        }
        buckets = newBuckets
    }

    return buckets.map { bucket in
        let sum = bucket.reduce(ColorBucket(0, 0, 0)) { (sum, pixel) -> ColorBucket in
            return ColorBucket(sum.x + pixel.x, sum.y + pixel.y, sum.z + pixel.z)
        }
        let count = CGFloat(bucket.count)
        return ColorBucket(sum.x / count, sum.y / count, sum.z / count)
    }
}

func splitBucket(_ bucket: [ColorBucket]) -> ([ColorBucket], [ColorBucket]) {
    var rMin: CGFloat = 1, rMax: CGFloat = 0
    var gMin: CGFloat = 1, gMax: CGFloat = 0
    var bMin: CGFloat = 1, bMax: CGFloat = 0

    for pixel in bucket {
        if pixel.x < rMin { rMin = pixel.x }
        if pixel.x > rMax { rMax = pixel.x }
        if pixel.y < gMin { gMin = pixel.y }
        if pixel.y > gMax { gMax = pixel.y }
        if pixel.z < bMin { bMin = pixel.z }
        if pixel.z > bMax { bMax = pixel.z }
    }

    let rRange = rMax - rMin
    let gRange = gMax - gMin
    let bRange = bMax - bMin

    let longestRange = max(rRange, gRange, bRange)

    if longestRange == rRange {
        return bucket.parallelSorted { $0.x < $1.x }.split()
    } else if longestRange == gRange {
        return bucket.parallelSorted { $0.y < $1.y }.split()
    } else {
        return bucket.parallelSorted { $0.z < $1.z }.split()
    }
}

extension Array {
    func split() -> ([Element], [Element]) {
        let middle = count / 2
        let left = Array(self[0..<middle])
        let right = Array(self[middle..<count])
        return (left, right)
    }

    func parallelSorted(by areInIncreasingOrder: @escaping (Element, Element) -> Bool) -> [Element] {
        var sortedArray = self
        DispatchQueue.concurrentPerform(iterations: 1) { _ in
            sortedArray.sort(by: areInIncreasingOrder)
        }
        return sortedArray
    }
}
