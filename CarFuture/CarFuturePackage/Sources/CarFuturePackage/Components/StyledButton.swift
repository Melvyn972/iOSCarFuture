//
//  StyledButton.swift
//  CarFuturePackage
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI

public struct StyledButton: View {
    private let title: String
    private let systemImage: String?
    private let action: () -> Void

    public init(title: String, systemImage: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.systemImage = systemImage
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack {
                if let systemImage {
                    Image(systemName: systemImage)
                }
                Text(title)
                    .fontWeight(.semibold)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(Theme.gradient)
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 6)
            .scaleEffect(1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: UUID())
        }
        .buttonStyle(.plain)
    }
}
