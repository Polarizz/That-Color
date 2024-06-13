//
//  GrayScale.swift
//  That Color
//
//  Created by Paul Wong on 6/12/24.
//

import SwiftUI

struct GrayscaleBlendMode: ViewModifier {
    var blendMode: BlendMode

    func body(content: Content) -> some View {
        content
            .blendMode(blendMode)
            .colorMultiply(.gray)
    }
}

extension View {
    func grayscaleBlendMode(_ blendMode: BlendMode) -> some View {
        self.modifier(GrayscaleBlendMode(blendMode: blendMode))
    }
}
