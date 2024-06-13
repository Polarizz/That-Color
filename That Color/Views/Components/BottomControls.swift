//
//  BottomControls.swift
//  That Color
//
//  Created by Paul Wong on 5/20/24.
//

import SwiftUI

struct BottomControls: View {

    @State private var orientation = UIDeviceOrientation.unknown

    @GestureState private var isTapped = false

    @EnvironmentObject var gridConfig: GridConfig

    @Binding var switchPalette: Bool

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
        .overlay(
            Button(action: {
                withAnimation(.smooth(duration: 0.25)) {
                    switchPalette.toggle()
                    gridConfig.rowCount = 3
                    gridConfig.columnCount = 3
                }
            }) {
                Image(systemName: switchPalette ? "swatchpalette.fill" : "swatchpalette")
                    .font(.title3)
                    .foregroundStyle(switchPalette ? .black : .white)
                    .offset(x: 1.5)
                    .padding(13)
                    .background(switchPalette ? .white : Color(.systemFill))
                    .clipShape(Circle())
            }
            , alignment: .trailing
        )
        .padding(.top, 10)
        .padding(.horizontal)
    }
}
