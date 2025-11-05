//
//  VehicleType.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import Foundation

enum VehicleType: String, CaseIterable, Identifiable, Codable {
    case car = "Voiture"
    case motorcycle = "Moto"

    var id: String { rawValue }
}
