//
//  PhotoGallery.swift
//  CarFuturePackage
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI

public struct PhotoGalleryView: View {
    private let images: [Image]

    public init(images: [Image]) {
        self.images = images
    }

    public var body: some View {
        TabView {
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
                .frame(height: 220)
                .padding(.horizontal)
            } else {
                ForEach(Array(images.enumerated()), id: \.offset) { _, img in
                    img
                        .resizable()
                        .scaledToFill()
                        .frame(height: 220)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .padding(.horizontal)
                        .transition(.opacity.combined(with: .scale))
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .automatic))
        .frame(maxWidth: .infinity)
    }
}
