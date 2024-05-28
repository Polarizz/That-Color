//
//  Orientation.swift
//  That Color
//
//  Created by Paul Wong on 5/28/24.
//

import SwiftUI
import Combine

class DeviceOrientationViewModel: ObservableObject {
    @Published var rotationAngle: Angle = .degrees(0)
    private var cancellables: Set<AnyCancellable> = []

    init() {
        NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)
            .map { _ in UIDevice.current.orientation }
            .sink { [weak self] orientation in
                switch orientation {
                case .landscapeLeft:
                    self?.rotationAngle = .degrees(90)
                case .landscapeRight:
                    self?.rotationAngle = .degrees(-90)
                case .portraitUpsideDown:
                    self?.rotationAngle = .degrees(180)
                default:
                    self?.rotationAngle = .degrees(0)
                }
            }
            .store(in: &cancellables)
    }
}
