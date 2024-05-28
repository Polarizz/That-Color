//
//  BottomControls.swift
//  That Color
//
//  Created by Paul Wong on 5/20/24.
//

import SwiftUI
//import PolyKit

struct BottomControls: View {

    @GestureState private var isTapped = false

    let width: CGFloat = 79
//    let action: () -> ()

    var body: some View {
        HStack(spacing: 0) {
            Spacer()

            Circle()
                .fill(.clear)
                .strokeBorder(Color.white, lineWidth: 3.5)
                .frame(width: width, height: width)
                .overlay(
                    Circle()
                        .fill(.white)
                        .frame(width: width - 12, height: width - 12)
                        .scaleEffect(isTapped ? 0.85 : 1)
                        .animation(.smooth(duration: 0.39), value: isTapped)

                )
                .simultaneousGesture(
                    DragGesture(minimumDistance: 0)
                        .updating($isTapped) { _, isTapped, _ in
                            isTapped = true
                        }
                        .onEnded { _ in
//                            action()
                        }
                )

            Spacer()
        }
        .overlay(
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .frame(width: 50, height: 50)
                .overlay(
                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                        .strokeBorder(.white.opacity(0.9), lineWidth: 2)
                )
            , alignment: .leading
        )
        .padding(.top, 10)
        .padding(.horizontal)
    }
}
