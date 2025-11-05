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
        VStack(alignment: .leading, spacing: 12) {
            if showHero {
                hero
                    .frame(height: 140)
                    .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
                    .overlay {
                        RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                            .strokeBorder(.white.opacity(0.08), lineWidth: 0.8)
                            .blendMode(.overlay)
                    }
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(vehicleName)
                    .font(.title3.weight(.semibold))
                    .lineLimit(1)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .accessibilityElement(children: .combine)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    statPill(label: statLeft.0, value: statLeft.1)
                    Spacer(minLength: 8)
                    statPill(label: statRight.0, value: statRight.1)
                }
                VStack(alignment: .leading, spacing: 8) {
                    statPill(label: statLeft.0, value: statLeft.1)
                    statPill(label: statRight.0, value: statRight.1)
                }
            }
            .font(.footnote.weight(.medium))
            .foregroundStyle(.secondary)
            .accessibilityElement(children: .contain)
        }
        .padding(Theme.cardPadding)
        .background {
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(accentGradient.opacity(0.12).blendMode(.plusLighter))
        }
        .overlay {
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .stroke(borderGradient.opacity(0.35), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .contentShape(RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous))
        .hoverEffect(.highlight)
        .animation(.snappy(duration: 0.25), value: vehicleName)
        .compositingGroup()
        .accessibilityElement(children: .contain)
    }


    private var hero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: Theme.cornerRadius, style: .continuous)
                .fill(.regularMaterial)
                .overlay(accentGradient.opacity(0.20))
                .overlay {
                    LinearGradient(colors: [
                        .black.opacity(0.22),
                        .black.opacity(0.00)
                    ], startPoint: .bottom, endPoint: .top)
                }

            if let heroImage {
                heroImage
                    .resizable()
                    .scaledToFill()
                    .overlay {
                        LinearGradient(colors: [
                            .black.opacity(0.28),
                            .black.opacity(0.00)
                        ], startPoint: .bottom, endPoint: .top)
                    }
                    .clipped()
                    .transition(.opacity.combined(with: .scale(scale: 1.02)))
                    .accessibilityHidden(true)
            } else {
                Image(systemName: "car.fill")
                    .resizable()
                    .scaledToFit()
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.secondary)
                    .padding(28)
                    .overlay {
                        AngularGradient(gradient: Gradient(colors: [
                            .accentColor.opacity(0.35),
                            .clear
                        ]), center: .center)
                        .blendMode(.softLight)
                        .opacity(0.6)
                    }
                    .accessibilityHidden(true)
            }
        }
    }

    private func statPill(label: String, value: String) -> some View {
        let symbol = symbolForLabel(label)

        let combinedText: Text =
            Text(verbatim: "\(normalizedLabel(label)):\u{00A0}")
            + Text(verbatim: value).fontWeight(.semibold).monospacedDigit()

        return HStack(spacing: 8) {
            if let symbol {
                Image(systemName: symbol)
                    .imageScale(.small)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            combinedText
                .lineLimit(1)
                .minimumScaleFactor(0.82)
                .allowsTightening(true)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background {
            Capsule(style: .continuous)
                .fill(.thinMaterial)
                .overlay(accentGradient.opacity(0.12))
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(.white.opacity(0.10), lineWidth: 0.8)
                        .blendMode(.overlay)
                }
        }
        .accessibilityLabel("\(normalizedLabel(label)): \(value)")
    }


    private var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.accentColor.opacity(0.28),
                Color.accentColor.opacity(0.06)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var borderGradient: LinearGradient {
        LinearGradient(
            colors: [
                .white.opacity(0.25),
                .black.opacity(0.15)
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func symbolForLabel(_ label: String) -> String? {
        let key = label.lowercased()
        if key.contains("vitesse") || key.contains("speed") { return "speedometer" }
        if key.contains("autonomie") || key.contains("range") { return "battery.100.bolt" }
        if key.contains("puissance") || key.contains("power") || key.contains("hp") || key.contains("cv") { return "engine.combustion" }
        if key.contains("consom") || key.contains("conso") || key.contains("efficiency") { return "leaf.fill" }
        if key.contains("co2") || key.contains("émission") || key.contains("emission") { return "cloud.fill" }
        if key.contains("prix") || key.contains("price") || key.contains("€") || key.contains("eur") { return "eurosign" }
        if key.contains("charge") || key.contains("charging") { return "bolt.car" }
        if key.contains("kg") || key.contains("poids") || key.contains("weight") { return "scalemass" }
        if key.contains("km") || key.contains("distance") { return "road.lanes" }
        if key.contains("0-100") || key.contains("0–100") || key.contains("0 to 100") { return "timer" }
        return nil
    }

    private func normalizedLabel(_ label: String) -> String {
        let lower = label.lowercased()
        if lower == "kg" { return "KG" }
        if lower == "cv" { return "CV" }
        return label.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
