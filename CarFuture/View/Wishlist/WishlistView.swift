//
//  WishlistView.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI
import CarFuturePackage

struct WishlistView: View {
    @EnvironmentObject private var store: GarageStore

    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Total global: \(store.globalWishlistTotal.currencyString)").bold()) {
                    EmptyView()
                }
                ForEach(store.vehicles) { v in
                    if !v.wishlist.isEmpty {
                        Section("\(v.name) • \(v.wishlist.count) pièce(s) • \(v.wishlistTotal.currencyString)") {
                            ForEach(v.wishlist) { part in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(part.name).font(.body)
                                        if let link = part.url, let url = URL(string: link) {
                                            Link(destination: url) {
                                                Label("Lien", systemImage: "link")
                                                    .font(.caption)
                                            }
                                            .foregroundStyle(.secondary)
                                        }
                                    }
                                    Spacer()
                                    Text(part.price.currencyString)
                                        .font(.headline)
                                }
                                .contentShape(Rectangle())
                            }
                        }
                    }
                }
            }
            .navigationTitle("Wishlist")
        }
    }
}
