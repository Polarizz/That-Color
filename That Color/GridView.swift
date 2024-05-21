//
//  GridView.swift
//  That Color
//
//  Created by Paul Wong on 5/20/24.
//

import SwiftUI

struct GridView: View {

    @StateObject private var colorComputation = ColorComputation()
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var scrollOffset: CGFloat = 0.0
    @State private var scrollOffsetSmall: CGFloat = 0.0

    let columns = Array(repeating: GridItem(.fixed(UIScreen.main.bounds.width / 10), spacing: 0), count: 10)
    let prefetchThreshold = 300 // Adjust this to determine how many items before the end to trigger pre-fetching

    let columnsSmall = Array(repeating: GridItem(.fixed(UIScreen.main.bounds.width / 6), spacing: 0), count: 6)

    var body: some View {
        ZStack {
            VStack {
                ScrollView {
                    ZStack {
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

                        GeometryReader { proxy in
                            let offset = proxy.frame(in: .named("smallScroll")).minY
                            Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                        }
                    }
                }
                .onAppear {
                    colorComputation.computeNextBatch()
                }
                .scaleEffect(0.61, anchor: .top)
                .offset(y: scrollOffsetSmall)
                .coordinateSpace(name: "smallScroll")
                .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                    scrollOffsetSmall = value
                    print("Small Scroll Offset: \(scrollOffsetSmall)")
                }
            }

            VStack {
                ScrollView {
                    ZStack {
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

                        GeometryReader { proxy in
                            let offset = proxy.frame(in: .named("scroll")).minY
                            Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                        }
                    }
                }
                .onAppear {
                    colorComputation.computeNextBatch()
                }
                .opacity(scale < 1.65 ? 0.5 : 0)
                .animation(.easeInOut(duration: 0.2), value: scale)
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
                    scrollOffset = value
                    print("Scroll Offset: \(scrollOffset)")
                }
                .offset(y: scrollOffset)
            }
        }
        .scaleEffect(scale, anchor: .top)
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    self.scale = max(self.lastScale * value, 1.0)
                }
                .onEnded { _ in
                    withAnimation {
                        self.scale = max(self.scale, 1.0)
                    }
                    self.lastScale = self.scale
                }
        )
    }
}

struct GridViewSmall: View {
    @StateObject private var colorComputation = ColorComputation()
    let columns = Array(repeating: GridItem(.fixed(UIScreen.main.bounds.width / 6), spacing: 0), count: 6)
    let prefetchThreshold = 300 // Adjust this to determine how many items before the end to trigger pre-fetching

    var body: some View {
        ScrollView {
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
        }
        .onAppear {
            colorComputation.computeNextBatch()
        }
        .scaleEffect(0.61, anchor: .top)
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0.0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
