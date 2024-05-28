//
//  CameraView.swift
//  That Color
//
//  Created by Paul Wong on 5/16/24.
//

import SwiftUI
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    @Binding var paletteColors: [Color]
    var colorCount: Int // dynamically update the number of colors based on selection

    class Coordinator: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
        var parent: CameraView
        private var lastUpdateTime: TimeInterval = 0
        private var paletteHistory: [[UIColor]] = []
        private let maxHistoryCount = 3

        init(parent: CameraView) {
            self.parent = parent
        }

        func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            let currentTime = CACurrentMediaTime()
            if currentTime - lastUpdateTime < 0.01 { return }
            lastUpdateTime = currentTime

            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext(options: nil)
            guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else { return }
            let uiImage = UIImage(cgImage: cgImage)

            DispatchQueue.global(qos: .userInitiated).async {
                var colors = uiImage.extractColors(colorCount: self.parent.colorCount)
                colors = self.ensurePaletteSize(colors, targetSize: self.parent.colorCount)
                DispatchQueue.main.async {
                    self.addPaletteToHistory(colors)
                    self.parent.paletteColors = self.calculateAveragePalette()
                }
            }
        }

        private func addPaletteToHistory(_ palette: [UIColor]) {
            paletteHistory.append(palette)
            if paletteHistory.count > maxHistoryCount {
                paletteHistory.removeFirst()
            }
        }

        private func ensurePaletteSize(_ palette: [UIColor], targetSize: Int) -> [UIColor] {
            var result = palette
            if palette.count > targetSize {
                result = Array(palette.prefix(targetSize))
            } else {
                while result.count < targetSize {
                    result.append(.clear)
                }
            }
            return result
        }

        private func calculateAveragePalette() -> [Color] {
            guard !paletteHistory.isEmpty else { return [] }

            var averagePalette = [UIColor]()
            let paletteCount = paletteHistory.first!.count

            for i in 0..<paletteCount {
                var redTotal: CGFloat = 0
                var greenTotal: CGFloat = 0
                var blueTotal: CGFloat = 0
                var count: CGFloat = 0

                for palette in paletteHistory {
                    if i < palette.count {
                        let color = palette[i]
                        var red: CGFloat = 0
                        var green: CGFloat = 0
                        var blue: CGFloat = 0
                        color.getRed(&red, green: &green, blue: &blue, alpha: nil)
                        redTotal += red
                        greenTotal += green
                        blueTotal += blue
                        count += 1
                    }
                }

                let averageColor = UIColor(red: redTotal / count, green: greenTotal / count, blue: blueTotal / count, alpha: 1.0)
                averagePalette.append(averageColor)
            }

            return averagePalette.map { Color($0) }
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .low // Lower resolution for reduced resource usage

        guard let videoCaptureDevice = selectCaptureDevice() else { return viewController }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return viewController
        }

        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            return viewController
        }

        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(context.coordinator, queue: DispatchQueue(label: "videoQueue", qos: .userInitiated, attributes: .concurrent))
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = viewController.view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        viewController.view.layer.addSublayer(previewLayer)

        captureSession.startRunning()

        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    private func selectCaptureDevice() -> AVCaptureDevice? {
        return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
    }
}
