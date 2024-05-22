//
//  GridView.swift
//  That Color
//
//  Created by Paul Wong on 5/20/24.
//

import SwiftUI

struct GridView: View {
    
    @ObservedObject var colorComputation: ColorComputation
    let segment: Int
    
    @State private var lastScale: CGFloat = 1.0
    @State private var scrollOffset: CGFloat = 0.0
    @State private var previousScale: CGFloat = 1.0
    @State private var velocity: CGFloat = 0.0
    @State private var scale: CGFloat = 1.0
    @State private var zoomed: Bool = false
    @State private var lastTime: TimeInterval = 0.0
    
    let columns = Array(repeating: GridItem(.fixed(UIScreen.main.bounds.width / 10), spacing: 0), count: 10)
    let columnsSmall = Array(repeating: GridItem(.fixed(UIScreen.main.bounds.width / 6), spacing: 0), count: 6)
    let prefetchThreshold = 300 // Adjust this to determine how many items before the end to trigger pre-fetching
    
    var body: some View {
        ScrollView {
            ZStack(alignment: .top) {
                LazyVGrid(columns: columnsSmall, spacing: 0) {
                    ForEach(0..<colorComputation.sortedColors[segment].count, id: \.self) { index in
                        let color = colorComputation.sortedColors[segment][index]
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(Color(red: color.0, green: color.1, blue: color.2))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                RoundedRectangle(cornerRadius: 9, style: .continuous)
                                    .strokeBorder(.black.opacity(0.13), lineWidth: 5)
                            )
                            .onAppear {
                                if index >= colorComputation.sortedColors[segment].count - prefetchThreshold {
                                    colorComputation.computeNextBatch(segment: segment)
                                }
                            }
                            .padding(4)
                    }
                }
                .scaleEffect(0.6, anchor: .top)
                .opacity(zoomed ? 1 : 0)
                .animation(.smooth(duration: 0.5), value: zoomed)
                .zIndex(1)
                
                LazyVGrid(columns: columns, spacing: 0) {
                    ForEach(0..<colorComputation.sortedColors[segment].count, id: \.self) { index in
                        let color = colorComputation.sortedColors[segment][index]
                        RoundedRectangle(cornerRadius: 5, style: .continuous)
                            .fill(Color(red: color.0, green: color.1, blue: color.2))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                RoundedRectangle(cornerRadius: 5, style: .continuous)
                                    .strokeBorder(.black.opacity(0.13), lineWidth: 3)
                            )
                            .onAppear {
                                if index >= colorComputation.sortedColors[segment].count - prefetchThreshold {
                                    colorComputation.computeNextBatch(segment: segment)
                                }
                            }
                            .padding(2.5)
                    }
                }
                .opacity(zoomed ? 0 : 1)
                .animation(.smooth(duration: 0.5), value: zoomed)
                .zIndex(0)
                
                GeometryReader { proxy in
                    let offset = proxy.frame(in: .named("scroll")).minY
                    Color.clear.preference(key: ScrollViewOffsetPreferenceKey.self, value: offset)
                }
            }
            .ignoresSafeArea()
        }
        .onAppear {
            colorComputation.computeNextBatch(segment: segment)
        }
        .animation(.easeInOut(duration: 0.2), value: scale)
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollViewOffsetPreferenceKey.self) { value in
            scrollOffset = value
        }
        .scaleEffect(scale, anchor: .top)
        .gesture(
            MagnificationGesture()
                .onChanged { value in
                    let deltaScale = value - 1.0
                    scale = max(lastScale * value, 1.0)
                    velocity = deltaScale / CGFloat(CACurrentMediaTime() - lastTime)
                    lastTime = CACurrentMediaTime()
                    previousScale = value
                    
                    withAnimation(.smooth(duration: 0.3)) {
                        zoomed = scale >= 1.65
                    }
                }
                .onEnded { _ in
                    withAnimation(.smooth(duration: 0.3)) {
                        if velocity > 0 {
                            zoomed = true
                            scale = 1.65
                        } else {
                            zoomed = false
                            scale = 1
                        }
                    }
                    
                    lastScale = scale
                    previousScale = 1.0
                    velocity = 0
                }
        )
        .background(.mainBackground)
        .overlay(
            LinearGradient(
                gradient: Gradient(colors: [Color.mainBackground.opacity(0.0), Color.mainBackground.opacity(0.6)]),
                startPoint: .bottom,
                endPoint: .top
            )
            .frame(height: 320)
            .padding([.horizontal, .top], -40)
            .allowsHitTesting(false)
            .ignoresSafeArea()
            , alignment: .top
        )
        .overlay(
            LinearGradient(
                gradient: Gradient(colors: [Color.mainBackground.opacity(0.0), Color.mainBackground.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 390)
            .padding([.horizontal, .bottom], -40)
            .allowsHitTesting(false)
            .ignoresSafeArea()
            , alignment: .bottom
        )
        .overlay(
            Text("79%")
                .font(.custom("BNHightideRegular", size: 70))
                .foregroundStyle(.primaryLabel)
                .shadow(color: .black.opacity(0.19), radius: 1, x: 10, y: 10)
                .padding()
            , alignment: .top
        )
        .overlay(
            HStack(spacing: 0) {
                Spacer()
                
                Circle()
                    .fill(.primaryLabel)
                    .frame(width: 80, height: 80)
                    .shadow(color: .black.opacity(0.19), radius: 1, x: 10, y: 10)
                
                Spacer()
            }
                .overlay(
                    Polygon(count: 3, relativeCornerRadius: 0.5)
                        .fill(.regularMaterial)
                        .frame(width: 50, height: 50)
                        .rotationEffect(.degrees(30))
                        .brightness(-0.1)
                    , alignment: .leading
                )
                .padding(.top, 10)
                .padding(.horizontal)
                .padding(.vertical, 30)
                .padding()
            , alignment: .bottom
        )
    }
}

struct ScrollViewOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0.0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
