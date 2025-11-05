//
//  Theme.swift
//  CarFuturePackage
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI

public enum Theme {
    public static let cornerRadius: CGFloat = 14
    public static let cardPadding: CGFloat = 12

    public static let gradient: LinearGradient = LinearGradient(
        colors: [Color.indigo, Color.purple],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
