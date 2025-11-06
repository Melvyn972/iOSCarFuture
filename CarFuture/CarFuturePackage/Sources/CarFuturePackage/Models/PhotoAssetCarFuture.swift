//
//  PhotoAssetCarFuture.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI

public struct PhotoAssetCarFuture: Identifiable, Codable, Hashable {
    public let id: UUID
    public let data: Data

    public init(id: UUID = UUID(), data: Data) {
        self.id = id
        self.data = data
    }

    public var image: Image? {
        #if canImport(UIKit)
        if let ui = UIImage(data: data) {
            return Image(uiImage: ui)
        }
        return nil
        #else
        return nil
        #endif
    }
}
