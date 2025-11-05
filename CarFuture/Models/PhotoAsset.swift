//
//  PhotoAsset.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI
import PhotosUI

struct PhotoAsset: Identifiable, Codable, Hashable {
    let id: UUID
    var data: Data

    init(id: UUID = UUID(), data: Data) {
        self.id = id
        self.data = data
    }
}

extension PhotoAsset {
    var image: Image? {
        guard let ui = UIImage(data: data) else { return nil }
        return Image(uiImage: ui)
    }
}
