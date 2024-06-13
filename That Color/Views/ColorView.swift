//
//  ColorView.swift
//  That Color
//
//  Created by Paul Wong on 6/10/24.
//

import SwiftUI

struct ColorView: View {

    var color: Color

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 10) {
                    if let hex = color.toHex {
                        Text("\(hex)")
                            .font(.custom("SFCamera-Medium", size: 34))
                    }
                    if let rgba = color.rgba {
                        Text("(\(Int(rgba.red * 255)), \(Int(rgba.green * 255)), \(Int(rgba.blue * 255)))")
                            .font(.custom("SFCamera", size: 21))
                    }
                }
                .foregroundStyle(.white)
                .blendMode(.difference)

                Spacer()
            }
            Spacer()
        }
        .padding()
        .background(color)
        .overlay(
            HStack(spacing: 5) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 16))

                Text("Tap to copy info")
                    .font(.custom("SFCamera", size: 16))
            }
            .foregroundStyle(.white)
            .blendMode(.difference)
            , alignment: .bottom
        )
    }
}

extension View {
    func onPressingChanged(_ action: @escaping (CGPoint?) -> Void) -> some View {
        modifier(SpatialPressingGestureModifier(action: action))
    }
}

extension Color {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
        guard let components = UIColor(self).cgColor.components, components.count >= 3 else {
            return nil
        }

        let r = components[0]
        let g = components[1]
        let b = components[2]
        let a = components.count >= 4 ? components[3] : 1.0

        return (red: r, green: g, blue: b, alpha: a)
    }

    var toHex: String? {
        guard let rgba = self.rgba else {
            return nil
        }

        if rgba.alpha != 1.0 {
            return String(format: "#%02lX%02lX%02lX%02lX",
                          lroundf(Float(rgba.red * 255)),
                          lroundf(Float(rgba.green * 255)),
                          lroundf(Float(rgba.blue * 255)),
                          lroundf(Float(rgba.alpha * 255)))
        } else {
            return String(format: "#%02lX%02lX%02lX",
                          lroundf(Float(rgba.red * 255)),
                          lroundf(Float(rgba.green * 255)),
                          lroundf(Float(rgba.blue * 255)))
        }
    }
}

struct RippleEffect<T: Equatable>: ViewModifier {
    var origin: CGPoint

    var trigger: T

    init(at origin: CGPoint, trigger: T) {
        self.origin = origin
        self.trigger = trigger
    }

    func body(content: Content) -> some View {
        let origin = origin
        let duration = duration

        content.keyframeAnimator(
            initialValue: 0,
            trigger: trigger
        ) { view, elapsedTime in
            view.modifier(RippleModifier(
                origin: origin,
                elapsedTime: elapsedTime,
                duration: duration
            ))
        } keyframes: { _ in
            MoveKeyframe(0)
            LinearKeyframe(duration, duration: duration)
        }
    }

    var duration: TimeInterval { 3 }
}

struct SpatialPressingGestureModifier: ViewModifier {
    var onPressingChanged: (CGPoint?) -> Void

    @State var currentLocation: CGPoint?

    init(action: @escaping (CGPoint?) -> Void) {
        self.onPressingChanged = action
    }

    func body(content: Content) -> some View {
        let gesture = SpatialPressingGesture(location: $currentLocation)

        content
            .gesture(gesture)
            .onChange(of: currentLocation, initial: false) { _, location in
                onPressingChanged(location)
            }
    }
}

struct SpatialPressingGesture: UIGestureRecognizerRepresentable {
    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        @objc
        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith other: UIGestureRecognizer
        ) -> Bool {
            true
        }
    }

    @Binding var location: CGPoint?

    func makeCoordinator(converter: CoordinateSpaceConverter) -> Coordinator {
        Coordinator()
    }

    func makeUIGestureRecognizer(context: Context) -> UILongPressGestureRecognizer {
        let recognizer = UILongPressGestureRecognizer()
        recognizer.minimumPressDuration = 0
        recognizer.delegate = context.coordinator

        return recognizer
    }

    func handleUIGestureRecognizerAction(
        _ recognizer: UIGestureRecognizerType, context: Context) {
            switch recognizer.state {
            case .began:
                location = context.converter.localLocation
            case .ended, .cancelled, .failed:
                location = nil
            default:
                break
            }
        }
}

struct RippleModifier: ViewModifier {
    var origin: CGPoint

    var elapsedTime: TimeInterval

    var duration: TimeInterval

    var amplitude: Double = 12
    var frequency: Double = 15
    var decay: Double = 8
    var speed: Double = 1200

    func body(content: Content) -> some View {
        let shader = ShaderLibrary.Ripple(
            .float2(origin),
            .float(elapsedTime),

            // Parameters
            .float(amplitude),
            .float(frequency),
            .float(decay),
            .float(speed)
        )

        let maxSampleOffset = maxSampleOffset
        let elapsedTime = elapsedTime
        let duration = duration

        content.visualEffect { view, _ in
            view.layerEffect(
                shader,
                maxSampleOffset: maxSampleOffset,
                isEnabled: 0 < elapsedTime && elapsedTime < duration
            )
        }
    }

    var maxSampleOffset: CGSize {
        CGSize(width: amplitude, height: amplitude)
    }
}
