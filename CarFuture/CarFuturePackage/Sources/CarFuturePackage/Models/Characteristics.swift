//
//  Characteristics.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import Foundation

public struct Characteristics: Codable, Hashable {
    public var weightKg: Int?
    public var seats: Int?
    public var horsepower: Int?
    public var torqueNm: Int?
    public var year: Int?

    public init(weightKg: Int? = nil,
                seats: Int? = nil,
                horsepower: Int? = nil,
                torqueNm: Int? = nil,
                year: Int? = nil) {
        self.weightKg = weightKg
        self.seats = seats
        self.horsepower = horsepower
        self.torqueNm = torqueNm
        self.year = year
    }
}
