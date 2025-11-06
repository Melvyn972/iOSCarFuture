//
//  PriceParser.swift
//  CarFuturePackage
//
//  Created by THIERRY-BELLEFOND Melvyn on 06/11/2025.
//


import Foundation

public enum PriceParser {
    public static func parsePrice(from raw: String) -> Double? {
        var s = raw.replacingOccurrences(of: #"[^0-9\.,]"#, with: "", options: .regularExpression)
        if s.contains(".") && s.contains(",") {
            s = s.replacingOccurrences(of: ".", with: "")
            s = s.replacingOccurrences(of: ",", with: ".")
        } else if s.contains(",") && !s.contains(".") {
            s = s.replacingOccurrences(of: ",", with: ".")
        } else {
            let comps = s.split(separator: ".")
            if comps.count > 2 {
                s = comps.joined()
            }
        }
        return Double(s)
    }
}
