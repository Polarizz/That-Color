//
//  Haptics.swift
//  That Color
//
//  Created by Paul Wong on 5/27/24.
//

import UIKit
import CoreHaptics

class Haptics {
    static let shared = Haptics()

    // Intensity property which can be changed from outside.
    var intensity: CGFloat = 1

    private init() { }

    // Modify the play function to accept an optional intensity.
    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle, customIntensity: CGFloat? = nil) {
        let intensityToUse = customIntensity ?? self.intensity
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred(intensity: intensityToUse)
    }

    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
