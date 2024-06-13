//
//  PalatteView.swift
//  That Color
//
//  Created by Paul Wong on 5/16/24.
//

import SwiftUI

struct PaletteView: View {

    @State private var orientation = UIDeviceOrientation.unknown

    @Namespace private var namespace

    @State private var fakeOffset: CGFloat = 0.0
    @State private var switchPalette = true

    @State var counter: Int = 0
    @State var origin: CGPoint = .zero

    @EnvironmentObject var gridConfig: GridConfig

    let items = ["3 COLORS", "4 COLORS", "6 COLORS", "9 COLORS", "12 COLORS"]

    var colors: [Color]
    @Binding var selectedItem: String
    @State var heightSize: String = "3 COLORS"

    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 5) {
                        Spacer()
                            .frame(height: geo.size.height / 2)

                        ForEach(Array(items.enumerated().dropFirst()), id: \.element) { index, item in
                            Button(action: {
                                selectedItem = item
                                heightSize = item
                                updateGridCounts()
                            }) {
                                VStack(alignment: .leading, spacing: 0) {
                                    Spacer()

                                    HStack(spacing: 0) {
                                        Text(item)
                                            .font(.custom("SFCamera", size: 15))
                                            .foregroundStyle(.white.opacity(0.39))
                                            .padding(.horizontal, 20)

                                        Spacer()
                                    }

                                    Spacer()
                                }
                                .overlay(
                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                        .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                                )
                                .contentShape(Rectangle())
                                .opacity(calculateOpacity(for: index))
                                .animation(.smooth(duration: 0.6))
                            }
                        }
                    }

                    Group {
                        if switchPalette {
                            Grid(horizontalSpacing: 5, verticalSpacing: 5) {
                                ForEach(0..<gridConfig.rowCount, id: \.self) { rowIndex in
                                    GridRow {
                                        ForEach(0..<gridConfig.columnCount, id: \.self) { columnIndex in
                                            let index = rowIndex * gridConfig.columnCount + columnIndex
                                            if index < colors.count {
                                                NavigationLink {
                                                    ColorView(color: colors[index])
                                                        .contentShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                                                        .navigationTransition(.zoom(
                                                            sourceID: colors[index], in: namespace))
                                                        .navigationBarBackButtonHidden(true)
                                                } label: {
                                                    colors[index]
                                                        .background(Color.black)
                                                        .cornerRadius(6)
                                                        .transition(.opacity)
                                                }
                                                .matchedTransitionSource(id: colors[index], in: namespace)
                                            }
                                        }
                                    }
                                }
                            }
                        } else {
                            MeshGradientView(colors: colors)
                        }
                    }
                    .frame(height: switchPalette ? calculateHeight(geoSize: geo.size) : nil)
                    .transformEffect(.identity)
                    .overlay(
                        ZStack {
                            Text(switchPalette ? selectedItem : "GRADIENT")
                                .font(.custom("SFCamera", size: 15))
                                .padding(.vertical, 3)
                                .padding(.horizontal, 6)
                                .foregroundColor(.white)
                                .blendMode(.difference)

                            Text(switchPalette ? selectedItem : "GRADIENT")
                                .font(.custom("SFCamera", size: 15))
                                .padding(.vertical, 3)
                                .padding(.horizontal, 6)
                                .background(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
                                .blendMode(.difference)
                        }
                        .padding(14)
                        .transformEffect(.identity)
                        , alignment: .bottomLeading
                    )
                    .overlay(
                        HStack {
                            Spacer()
                            Capsule()
                                .fill(Color.white)
                                .blendMode(.difference)
                                .frame(width: 100, height: 5)
                                .padding(9)
                            Spacer()
                        }
                            .padding(20)
                            .contentShape(Rectangle())
                            .padding(-20),
                        alignment: .bottom
                    )
                    .highPriorityGesture(
                        DragGesture()
                            .onChanged { value in
                                if switchPalette {
                                    fakeOffset = value.translation.height
                                    realtimeHandleDragChange(currentHeight: calculateHeight(geoSize: geo.size), geo: geo)
                                }
                            }
                            .onEnded { _ in
                                if switchPalette {
                                    handleDragChange(currentHeight: calculateHeight(geoSize: geo.size), geo: geo)
                                    fakeOffset = 0
                                }
                            }
                    )
                    .animation(.smooth(duration: 0.25))
                    .onPressingChanged { point in
                        if let point {
                            if !switchPalette {
                                origin = point
                                counter += 1
                            }
                        }
                    }
                    .modifier(RippleEffect(at: origin, trigger: counter))
                }
            }

            Spacer()

            BottomControls(switchPalette: $switchPalette)
                .padding(.vertical, 30)
        }
        .padding([.top, .horizontal])
        .background(Color.black)
    }

    private func updateGridCounts() {
        switch selectedItem {
        case "3 COLORS":
            gridConfig.rowCount = 3
            gridConfig.columnCount = 1
        case "4 COLORS":
            gridConfig.rowCount = 4
            gridConfig.columnCount = 1
        case "6 COLORS":
            gridConfig.rowCount = 6
            gridConfig.columnCount = 1
        case "9 COLORS":
            gridConfig.rowCount = 3
            gridConfig.columnCount = 3
        case "12 COLORS":
            gridConfig.rowCount = 4
            gridConfig.columnCount = 3
        default:
            gridConfig.rowCount = 1
            gridConfig.columnCount = 1
        }
    }

    private func calculateHeight(geoSize: CGSize) -> CGFloat {
        let baseHeight = geoSize.height / 2
        let itemHeight = geoSize.height / 8
        var extraHeight: CGFloat = 0

        switch heightSize {
        case "4 COLORS":
            extraHeight = itemHeight
        case "6 COLORS":
            extraHeight = itemHeight * 2
        case "9 COLORS":
            extraHeight = itemHeight * 3
        case "12 COLORS":
            extraHeight = itemHeight * 4
        default:
            extraHeight = 0
        }

        return baseHeight + fakeOffset + extraHeight
    }

    private func handleDragChange(currentHeight: CGFloat, geo: GeometryProxy) {
        let baseHeight = geo.size.height / 2
        let itemHeight = geo.size.height / 8
        let thresholds = [
            baseHeight + 10,
            baseHeight + itemHeight + 10,
            baseHeight + itemHeight * 2 + 10,
            baseHeight + itemHeight * 3 + 10
        ]

        if currentHeight < thresholds[0] {
            heightSize = "3 COLORS"
        } else if currentHeight < thresholds[1] {
            heightSize = "4 COLORS"
        } else if currentHeight < thresholds[2] {
            heightSize = "6 COLORS"
        } else if currentHeight < thresholds[3] {
            heightSize = "9 COLORS"
        } else {
            heightSize = "12 COLORS"
        }

        updateGridCounts()
    }

    private func realtimeHandleDragChange(currentHeight: CGFloat, geo: GeometryProxy) {
        let baseHeight = geo.size.height / 2
        let itemHeight = geo.size.height / 8
        let thresholds = [
            baseHeight + 10,
            baseHeight + itemHeight + 10,
            baseHeight + itemHeight * 2 + 10,
            baseHeight + itemHeight * 3 + 10
        ]

        if currentHeight < thresholds[0] {
            selectedItem = "3 COLORS"
        } else if currentHeight < thresholds[1] {
            selectedItem = "4 COLORS"
        } else if currentHeight < thresholds[2] {
            selectedItem = "6 COLORS"
        } else if currentHeight < thresholds[3] {
            selectedItem = "9 COLORS"
        } else {
            selectedItem = "12 COLORS"
        }

        updateGridCounts()
    }

    private func calculateOpacity(for index: Int) -> Double {
        let selectedOpacityLevels: [String: Int] = [
            "3 COLORS": 1,
            "4 COLORS": 2,
            "6 COLORS": 3,
            "9 COLORS": 4,
            "12 COLORS": 5
        ]

        if let opacityLevel = selectedOpacityLevels[selectedItem], index < opacityLevel {
            return 0.0
        }
        return 1.0
    }
}
