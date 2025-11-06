//
//  ParsedDetails.swift
//  CarFuturePackage
//
//  Created by THIERRY-BELLEFOND Melvyn on 06/11/2025.
//


import Foundation

public struct ParsedDetails {
    public var title: String?
    public var price: Double?
    public var year: Int?
    public var horsepower: Int?
    public var torqueNm: Int?
    public var seats: Int?
    public var weightKg: Int?
    public init(title: String? = nil,
                price: Double? = nil,
                year: Int? = nil,
                horsepower: Int? = nil,
                torqueNm: Int? = nil,
                seats: Int? = nil,
                weightKg: Int? = nil) {}
}

public enum WebsiteParsers {
    public static func parse(host: String, html: String) -> ParsedDetails {
        let h = host.lowercased()
        if h.contains("leboncoin") {
            return parseLeboncoin(html)
        } else if h.contains("mobile.de") || h.contains("mobilede") {
            return parseMobileDe(html)
        } else if h.contains("lacentrale") {
            return parseLaCentrale(html)
        } else {
            return parseGeneric(html)
        }
    }

    private static func parseLeboncoin(_ html: String) -> ParsedDetails {
        var out = ParsedDetails()
        out.title = extractMetaContent(for: "og:title", in: html) ?? extractTitleTag(in: html)
        let blocks = extractJSONLDBlocks(in: html)
        for block in blocks {
            if out.price == nil, let p = extractPriceFromJSONText(block) { out.price = p }
            if out.year == nil, let y = extractYearFromJSONText(block, keys: ["modelDate", "vehicleModelDate", "productionDate", "releaseDate", "year"]) { out.year = y }
            if out.horsepower == nil, let hp = extractHorsepowerFromJSONText(block) { out.horsepower = hp }
        }
        if out.price == nil, let p = extractPriceWithRegex(in: html) { out.price = p }
        if out.year == nil, let y = extractYearWithRegex(in: html) { out.year = y }
        if out.horsepower == nil, let hp = extractHorsepowerRegex(in: html) { out.horsepower = hp }
        return out
    }

    private static func parseMobileDe(_ html: String) -> ParsedDetails {
        var out = ParsedDetails()
        out.title = extractMetaContent(for: "og:title", in: html) ?? extractTitleTag(in: html)
        let blocks = extractJSONLDBlocks(in: html)
        for block in blocks {
            if out.price == nil, let p = extractPriceFromJSONText(block) { out.price = p }
            if out.year == nil, let y = extractYearFromJSONText(block, keys: ["productionDate", "firstRegistration", "releaseDate", "vehicleModelDate", "modelDate", "year"]) { out.year = y }
            if out.horsepower == nil, let hp = extractHorsepowerFromJSONText(block) { out.horsepower = hp }
        }
        if out.price == nil, let p = firstNumberForKeys(in: html, keys: ["price", "amount"]) { out.price = p }
        if out.year == nil, let y = firstYearForKeys(in: html, keys: ["firstRegistration", "year"]) { out.year = y }
        if out.price == nil, let p = extractPriceWithRegex(in: html) { out.price = p }
        if out.year == nil, let y = extractYearWithRegex(in: html) { out.year = y }
        if out.horsepower == nil, let hp = extractHorsepowerRegex(in: html) { out.horsepower = hp }
        return out
    }

    private static func parseLaCentrale(_ html: String) -> ParsedDetails {
        var out = ParsedDetails()
        out.title = extractMetaContent(for: "og:title", in: html) ?? extractTitleTag(in: html)
        let blocks = extractJSONLDBlocks(in: html)
        for block in blocks {
            if out.price == nil, let p = extractPriceFromJSONText(block) { out.price = p }
            if out.year == nil, let y = extractYearFromJSONText(block, keys: ["vehicleModelDate", "modelDate", "productionDate", "releaseDate", "year"]) { out.year = y }
            if out.horsepower == nil, let hp = extractHorsepowerFromJSONText(block) { out.horsepower = hp }
        }
        if out.price == nil, let p = firstNumberForKeys(in: html, keys: ["sellingPrice", "price", "amount"]) { out.price = p }
        if out.year == nil, let y = firstYearForKeys(in: html, keys: ["mec", "year", "annee"]) { out.year = y }
        if out.price == nil, let p = extractPriceWithRegex(in: html) { out.price = p }
        if out.year == nil, let y = extractYearWithRegex(in: html) { out.year = y }
        if out.horsepower == nil, let hp = extractHorsepowerRegex(in: html) { out.horsepower = hp }
        return out
    }

    private static func parseGeneric(_ html: String) -> ParsedDetails {
        var out = ParsedDetails()
        out.title = extractMetaContent(for: "og:title", in: html) ?? extractTitleTag(in: html)
        let blocks = extractJSONLDBlocks(in: html)
        for block in blocks {
            if out.price == nil, let p = extractPriceFromJSONText(block) { out.price = p }
            if out.year == nil, let y = extractYearFromJSONText(block, keys: ["year", "productionDate", "releaseDate", "vehicleModelDate", "modelDate"]) { out.year = y }
            if out.horsepower == nil, let hp = extractHorsepowerFromJSONText(block) { out.horsepower = hp }
        }
        if out.price == nil, let p = extractPriceWithRegex(in: html) { out.price = p }
        if out.year == nil, let y = extractYearWithRegex(in: html) { out.year = y }
        if out.horsepower == nil, let hp = extractHorsepowerRegex(in: html) { out.horsepower = hp }
        return out
    }

    private static func extractTitleTag(in html: String) -> String? {
        guard let open = html.range(of: "<title", options: .caseInsensitive) else { return nil }
        guard let gt = html[open.upperBound...].range(of: ">", options: []) else { return nil }
        guard let close = html[gt.upperBound...].range(of: "</title>", options: .caseInsensitive) else { return nil }
        return String(html[gt.upperBound..<close.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func extractMetaContent(for property: String, in html: String) -> String? {
        let escaped = NSRegularExpression.escapedPattern(for: property)
        let pattern = "<meta\\s+(?:property|name)=[\"']\(escaped)[\"'][^>]*content=[\"'](.*?)[\"']"
        return firstCapture(in: html, pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
    }

    private static func extractJSONLDBlocks(in html: String) -> [String] {
        let pattern = "<script[^>]*type=[\"']application/ld\\+json[\"'][^>]*>(.*?)</script>"
        let regex = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators])
        let nsrange = NSRange(html.startIndex..<html.endIndex, in: html)
        let matches = regex?.matches(in: html, options: [], range: nsrange) ?? []
        return matches.compactMap { m in
            guard m.numberOfRanges >= 2, let r = Range(m.range(at: 1), in: html) else { return nil }
            return String(html[r])
        }
    }

    private static func extractPriceFromJSONText(_ text: String) -> Double? {
        if let s = firstCapture(in: text, pattern: #""price"\s*:\s*"([0-9\.\s,]+)""#, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            return PriceParser.parsePrice(from: s)
        }
        if let s = firstCapture(in: text, pattern: #""price"\s*:\s*([0-9\.\s,]+)\b"#, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            return PriceParser.parsePrice(from: s)
        }
        if let s = firstCapture(in: text, pattern: #""offers"\s*:\s*\{[^}]*"price"\s*:\s*"([0-9\.\s,]+)""#, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            return PriceParser.parsePrice(from: s)
        }
        return nil
    }

    private static func extractYearFromJSONText(_ text: String, keys: [String]) -> Int? {
        for key in keys {
            let patternQuoted = #"\"\#(key)\"\s*:\s*\"(\d{4})\""#
            if let y = firstCapture(in: text, pattern: patternQuoted, options: [.caseInsensitive, .dotMatchesLineSeparators]), let val = Int(y), (1950...2035).contains(val) {
                return val
            }
            let patternUnquoted = #"\"\#(key)\"\s*:\s*(\d{4})\b"#
            if let y = firstCapture(in: text, pattern: patternUnquoted, options: [.caseInsensitive, .dotMatchesLineSeparators]), let val = Int(y), (1950...2035).contains(val) {
                return val
            }
        }
        return nil
    }

    private static func extractHorsepowerFromJSONText(_ text: String) -> Int? {
        if let hp = firstCapture(in: text, pattern: #""powerPS"\s*:\s*(\d{2,4})"#, options: [.caseInsensitive, .dotMatchesLineSeparators]), let v = Int(hp) {
            return v
        }
        if let hp = firstCapture(in: text, pattern: #""horsepower"\s*:\s*(\d{2,4})"#, options: [.caseInsensitive, .dotMatchesLineSeparators]), let v = Int(hp) {
            return v
        }
        if let hp = firstCapture(in: text, pattern: #"(\d{2,4})\s*(PS|Ch|CV)"#, options: [.caseInsensitive, .dotMatchesLineSeparators]), let v = Int(hp) {
            return v
        }
        return nil
    }

    private static func extractPriceWithRegex(in html: String) -> Double? {
        if let s = firstCapture(in: html, pattern: #"(\d{1,3}(?:[ \u00A0\u202F]?\d{3})+(?:[\,\.]\d{2})?)\s*€"#, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            return PriceParser.parsePrice(from: s)
        }
        if let s = firstCapture(in: html, pattern: #""price"\s*:\s*(\d{3,7})\b"#, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            return PriceParser.parsePrice(from: s)
        }
        return nil
    }

    private static func extractYearWithRegex(in html: String) -> Int? {
        if let y = firstCapture(in: html, pattern: #"(?is)(Année|Annee|MEC|Mise en circulation|Erstzulassung|Year)[^0-9]{0,30}(\d{4})"#, options: [.caseInsensitive, .dotMatchesLineSeparators]), let val = Int(y), (1950...2035).contains(val) {
            return val
        }
        if let y = firstCapture(in: html, pattern: #"\b(19[5-9]\d|20[0-3]\d)\b"#, options: [.caseInsensitive]), let val = Int(y), (1950...2035).contains(val) {
            return val
        }
        return nil
    }

    private static func extractHorsepowerRegex(in html: String) -> Int? {
        if let hp = firstCapture(in: html, pattern: #"(?i)\b(\d{2,4})\s*(ch|cv|ps)\b"#, options: [.caseInsensitive]), let v = Int(hp) {
            return v
        }
        return nil
    }

    private static func firstNumberForKeys(in html: String, keys: [String]) -> Double? {
        for key in keys {
            let patternQuoted = #""\#(key)"\s*:\s*"([0-9\.\s,]+)""#
            if let s = firstCapture(in: html, pattern: patternQuoted, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
                if let v = PriceParser.parsePrice(from: s) { return v }
            }
            let patternUnquoted = #""\#(key)"\s*:\s*([0-9\.\s,]+)\b"#
            if let s = firstCapture(in: html, pattern: patternUnquoted, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
                if let v = PriceParser.parsePrice(from: s) { return v }
            }
        }
        return nil
    }

    private static func firstYearForKeys(in html: String, keys: [String]) -> Int? {
        for key in keys {
            let patternQuoted = #""\#(key)"\s*:\s*"(\d{4})""#
            if let s = firstCapture(in: html, pattern: patternQuoted, options: [.caseInsensitive, .dotMatchesLineSeparators]), let v = Int(s), (1950...2035).contains(v) {
                return v
            }
            let patternUnquoted = #""\#(key)"\s*:\s*(\d{4})\b"#
            if let s = firstCapture(in: html, pattern: patternUnquoted, options: [.caseInsensitive, .dotMatchesLineSeparators]), let v = Int(s), (1950...2035).contains(v) {
                return v
            }
        }
        return nil
    }

    private static func firstCapture(in text: String, pattern: String, options: NSRegularExpression.Options = []) -> String? {
        let regex = try? NSRegularExpression(pattern: pattern, options: options)
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let m = regex?.firstMatch(in: text, options: [], range: range), m.numberOfRanges >= 2 else { return nil }
        guard let r = Range(m.range(at: 1), in: text) else { return nil }
        return String(text[r])
    }
}
