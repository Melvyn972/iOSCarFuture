//
//  PhotoGallery.swift
//  CarFuturePackage
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI

public struct PhotoGalleryView: View {
    private let images: [Image]
    private let height: CGFloat
    private let horizontalPadding: CGFloat
    @State private var selection: Int = 0

    public init(images: [Image], height: CGFloat = 320, horizontalPadding: CGFloat = 16) {
        self.images = images
        self.height = height
        self.horizontalPadding = horizontalPadding
    }

    public var body: some View {
        TabView(selection: $selection) {
            if images.isEmpty {
                ZStack {
                    RoundedRectangle(cornerRadius: 16).fill(.ultraThinMaterial)
                    VStack(spacing: 8) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                        Text("Aucune photo").foregroundStyle(.secondary)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .tag(0)
            } else {
                ForEach(Array(images.enumerated()), id: \.offset) { idx, img in
                    img
                        .resizable()
                        .scaledToFill()
                        .frame(maxWidth: .infinity, minHeight: height, maxHeight: height)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .tag(idx)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(height: height)
        .padding(.horizontal, horizontalPadding)
        .animation(.easeInOut, value: images.count)
    }
}
