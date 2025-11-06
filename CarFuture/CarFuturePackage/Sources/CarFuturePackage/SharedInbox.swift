//
//  SharedInbox.swift
//  CarFuturePackage
//
//  Created by THIERRY-BELLEFOND Melvyn on 06/11/2025.
//


import Foundation

public enum SharedInbox {
    private static var inboxURL: URL? {
        AppGroup.containerURL?.appendingPathComponent("inbox.json")
    }

    public static func load() -> [VehicleToBuy] {
        guard let url = inboxURL, let data = try? Data(contentsOf: url) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([VehicleToBuy].self, from: data)) ?? []
    }

    public static func append(_ item: VehicleToBuy) {
        var items = load()
        items.append(item)
        save(items)
    }

    public static func clear() {
        guard let url = inboxURL else { return }
        try? FileManager.default.removeItem(at: url)
    }

    private static func save(_ items: [VehicleToBuy]) {
        guard let url = inboxURL else { return }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted]
        if let data = try? encoder.encode(items) {
            try? data.write(to: url, options: [.atomic])
        }
    }
}