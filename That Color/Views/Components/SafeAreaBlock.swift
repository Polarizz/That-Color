//
//  SafeAreaBlock.swift
//  That Color
//
//  Created by Paul Wong on 5/28/24.
//

import SwiftUI

struct SafeAreaBlockBottom: View {

    @Environment(\.horizontalSizeClass) var sizeClass
    @Environment(\.colorScheme) private var colorScheme

    @State var height: CGFloat = 120

    var minimized: Bool = false

    var body: some View {
        VisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
//        Color.red
            .frame(
                width: 9999,
                height: height*2
            )
            .padding(.horizontal, -200)
            .blur(radius: 20)
            .contrast(colorScheme == .dark ? 0.53 : 1.5)
            .saturation(1.39)
            .brightness(-0.2)
            .offset(
                y:
                    height
            )
            .ignoresSafeArea(.container)
            .allowsHitTesting(false)
    }
}

struct VisualEffectView: UIViewRepresentable {
    var effect: UIVisualEffect?
    func makeUIView(context: UIViewRepresentableContext<Self>) -> UIVisualEffectView { UIVisualEffectView() }
    func updateUIView(_ uiView: UIVisualEffectView, context: UIViewRepresentableContext<Self>) { uiView.effect = effect }
}
