//
//  PalatteView.swift
//  That Color
//
//  Created by Paul Wong on 5/16/24.
//

import SwiftUI

struct PaletteView: View {

    @GestureState private var dragOffset: CGFloat = 0.0

    @EnvironmentObject var gridConfig: GridConfig

    let items = ["1×4", "1×6", "3×3", "3×4"]

    var colors: [Color]
    @Binding var selectedItem: String


    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Spacer()
                        .frame(height: 300)

                    ForEach(Array(items.enumerated()), id: \.element) { index, item in
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer()

                            HStack(spacing: 0) {
                                Text(item)
                                    .font(.custom("SFCamera", size: 17))
                                    .foregroundStyle(.white.opacity(0.39))
                                    .padding(.horizontal)
                                    .onTapGesture {
                                        selectedItem = item
                                        updateGridCounts()
                                    }

                                Spacer()
                            }

                            Spacer()
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
                        )
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
                                    } else {
                                        Color.clear
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
                .frame(height: 280)
                .overlay(
                    Capsule()
                        .fill(Color.white)
                        .blendMode(.difference)
                        .frame(width: 100, height: 5)
                        .padding(9)
                        .gesture(
                            DragGesture()
                                .updating($dragOffset) { value, state, _ in
                                    state = value.translation.height
                                }
                        )
                        .contentShape(Rectangle())
                    , alignment: .bottom
                )
                .animation(.smooth(duration: 0.3))
            }

            Spacer()

            BottomControls()
                .padding(.vertical, 30)
        }
        .padding([.top, .horizontal])
        .padding(.top, 24)
        .background(Color.black)
    }

    private func updateGridCounts() {
        switch selectedItem {
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
}
