//
//  VehicleCard.swift
//  CarFuturePackage
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI

public struct VehicleCard: View {
    private let vehicleName: String
    private let subtitle: String
    private let heroImage: Image?
    private let statLeft: (String, String)
    private let statRight: (String, String)
    private let showHero: Bool

    public init(
        vehicleName: String,
        subtitle: String,
        heroImage: Image?,
        statLeft: (String, String),
        statRight: (String, String),
        showHero: Bool = true
    ) {
        self.vehicleName = vehicleName
        self.subtitle = subtitle
        self.heroImage = heroImage
        self.statLeft = statLeft
        self.statRight = statRight
        self.showHero = showHero
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if showHero {
                ZStack {
                    RoundedRectangle(cornerRadius: Theme.cornerRadius)
                        .fill(.ultraThinMaterial)
                    if let heroImage {
                        heroImage
                            .resizable()
                            .scaledToFill()
                    } else {
                        Image(systemName: "car.fill")
                            .resizable()
                            .scaledToFit()
                            .padding(24)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(height: 110)
                .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(vehicleName)
                    .font(.headline)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            HStack {
                statView(statLeft.0, statLeft.1)
                Spacer()
                statView(statRight.0, statRight.1)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(Theme.cardPadding)
        .background {
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        }
    }

    private func statView(_ label: String, _ value: String) -> some View {
        HStack(spacing: 6) {
            Text(label + ":")
            Text(value).bold()
        }
    }
}
