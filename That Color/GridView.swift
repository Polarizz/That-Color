//
//  GridView.swift
//  That Color
//
//  Created by Paul Wong on 5/20/24.
//

import SwiftUI

struct GridView: View {

    @StateObject private var colorComputation = ColorComputation()

    @GestureState var scale: CGFloat = 1.0

    @State private var lastScale: CGFloat = 1.0
    @State private var scrollOffset: CGFloat = 0.0
    @State private var previousScale: CGFloat = 1.0
    @State private var velocity: CGFloat = 0.0
    @State private var fakeScale: CGFloat = 1.0
    @State private var zoomed: Bool = false
    @State private var lastTime: TimeInterval = 0.0

    let columns = Array(repeating: GridItem(.fixed(UIScreen.main.bounds.width / 10), spacing: 0), count: 10)
    let columnsSmall = Array(repeating: GridItem(.fixed(UIScreen.main.bounds.width / 6), spacing: 0), count: 6)
    let prefetchThreshold = 300 // Adjust this to determine how many items before the end to trigger pre-fetching

    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                LazyVGrid(columns: columnsSmall, spacing: 0) {
                    ForEach(0..<colorComputation.sortedColors.count, id: \.self) { index in
                        let color = colorComputation.sortedColors[index]
                        Rectangle()
                            .fill(Color(red: color.0, green: color.1, blue: color.2))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Text("\(index)")
                                    .foregroundColor(.white)
                                    .font(.caption2)
                            )
                            .onAppear {
                                if index >= colorComputation.sortedColors.count - prefetchThreshold {
                                    colorComputation.computeNextBatch()
                                }
                            }
                    }
                }
                .scaleEffect(0.61, anchor: .top)
                .opacity(zoomed ? 1 : 0)
                .zIndex(1)

                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<colorComputation.sortedColors.count, id: \.self) { index in
                        let color = colorComputation.sortedColors[index]
                        Rectangle()
                            .fill(Color(red: color.0, green: color.1, blue: color.2))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                Text("\(index)")
                                    .foregroundColor(.white)
                                    .font(.caption2)
                            )
                            .onAppear {
                                if index >= colorComputation.sortedColors.count - prefetchThreshold {
                                    colorComputation.computeNextBatch()
                                }
                            }
                    }
                }
                .zIndex(0)

                GeometryReader { proxy in
                    let offset = proxy.frame(in: .named("scroll")).minY
                    Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                }
            }
        }
        .onAppear {
            colorComputation.computeNextBatch()
        }
        .animation(.easeInOut(duration: 0.2), value: scale)
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
        .scaleEffect(scale + (fakeScale - scale), anchor: .top)
        .gesture(
            MagnificationGesture()
                .updating($scale) { value, state, _ in
                    state = max(lastScale * value, 1.0)
                }
                .onChanged { value in
                    let currentTime = CACurrentMediaTime()
                    let deltaTime = currentTime - lastTime
                    let deltaScale = value - previousScale

                    velocity = deltaScale / CGFloat(deltaTime)
                    lastTime = currentTime
                    fakeScale = max(lastScale * value, 1.0)
                    previousScale = value

                    withAnimation(.smooth(duration: 0.3)) {
                        zoomed = fakeScale >= 1.65
                    }
                }
                .onEnded { _ in
                    withAnimation(.smooth(duration: 0.39)) {
                        if velocity > 0 {
                            zoomed = true
                            fakeScale = 1.65
                        } else {
                            zoomed = false
                            fakeScale = 1
                        }
                    }

                    lastScale = fakeScale
                    previousScale = 1.0
                    velocity = 0
                }
        )
        .animation(.smooth(duration: 0.39), value: scale)
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0.0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
