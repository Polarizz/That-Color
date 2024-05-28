//
//  PalatteView.swift
//  That Color
//
//  Created by Paul Wong on 5/16/24.
//

import SwiftUI

struct PaletteView: View {

    @State private var fakeOffset: CGFloat = 0.0

    @EnvironmentObject var gridConfig: GridConfig

    let items = ["1×3", "1×4", "1×6", "3×3", "3×4"]

    var colors: [Color]
    @Binding var selectedItem: String
    @State var heightSize: String = "1×3"

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
                                            .font(.custom("SFCamera", size: 17))
                                            .foregroundStyle(.white.opacity(0.39))
                                            .padding(.horizontal)

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
                                .animation(.smooth(duration: 0.39))
                            }
                        }
                    }

                    VStack(spacing: 5) {
                        Grid(horizontalSpacing: 5, verticalSpacing: 5) {
                            ForEach(0..<gridConfig.rowCount, id: \.self) { rowIndex in
                                GridRow {
                                    ForEach(0..<gridConfig.columnCount, id: \.self) { columnIndex in
                                        let index = rowIndex * gridConfig.columnCount + columnIndex
                                        if index < colors.count {
                                            colors[index]
                                                .frame(minHeight: 0, maxHeight: .infinity)
                                                .background(Color.black)
                                                .cornerRadius(6)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                        .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                                                )
                                        }
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                    .frame(height: calculateHeight(geoSize: geo.size))
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
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                fakeOffset = value.translation.height
                                realtimeHandleDragChange(currentHeight: calculateHeight(geoSize: geo.size), geo: geo)
                            }
                            .onEnded { _ in
                                handleDragChange(currentHeight: calculateHeight(geoSize: geo.size), geo: geo)
                                fakeOffset = 0
                            }
                    )
                    .animation(.smooth(duration: 0.3))
                }
            }

            Spacer()

            BottomControls()
                .padding(.vertical, 30)
        }
        .padding([.top, .horizontal])
        .background(Color.black)
    }

    private func updateGridCounts() {
        switch selectedItem {
        case "1×3":
            gridConfig.rowCount = 3
            gridConfig.columnCount = 1
        case "1×4":
            gridConfig.rowCount = 4
            gridConfig.columnCount = 1
        case "1×6":
            gridConfig.rowCount = 6
            gridConfig.columnCount = 1
        case "3×3":
            gridConfig.rowCount = 3
            gridConfig.columnCount = 3
        case "3×4":
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
        case "1×4":
            extraHeight = itemHeight
        case "1×6":
            extraHeight = itemHeight * 2
        case "3×3":
            extraHeight = itemHeight * 3
        case "3×4":
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
            heightSize = "1×3"
        } else if currentHeight < thresholds[1] {
            heightSize = "1×4"
        } else if currentHeight < thresholds[2] {
            heightSize = "1×6"
        } else if currentHeight < thresholds[3] {
            heightSize = "3×3"
        } else {
            heightSize = "3×4"
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
            selectedItem = "1×3"
        } else if currentHeight < thresholds[1] {
            selectedItem = "1×4"
        } else if currentHeight < thresholds[2] {
            selectedItem = "1×6"
        } else if currentHeight < thresholds[3] {
            selectedItem = "3×3"
        } else {
            selectedItem = "3×4"
        }

        updateGridCounts()
    }

    private func calculateOpacity(for index: Int) -> Double {
        let selectedOpacityLevels: [String: Int] = [
            "1×3": 1,
            "1×4": 2,
            "1×6": 3,
            "3×3": 4,
            "3×4": 5
        ]

        if let opacityLevel = selectedOpacityLevels[selectedItem], index < opacityLevel {
            return 0.0
        }
        return 1.0
    }
}
