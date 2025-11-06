//
//  VehicleType.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import Foundation

public enum VehicleType: String, CaseIterable, Identifiable, Codable {
    case car = "Voiture"
    case motorcycle = "Moto"

    public var id: String { rawValue }
}
