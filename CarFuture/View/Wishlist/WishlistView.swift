//
//  WishlistView.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI

private enum WishlistTab: String, CaseIterable, Identifiable {
    case parts = "Pièces"
    case listings = "Annonces"

    var id: String { rawValue }
}

private enum WishlistSheet: Identifiable {
    case editPart(vehicleID: UUID, part: PartItem)
    case editListing(VehicleToBuy)

    var id: String {
        switch self {
        case .editPart(_, let part): return "editPart_\(part.id)"
        case .editListing(let v): return "editListing_\(v.id)"
        }
    }
}

struct WishlistView: View {
    @EnvironmentObject private var store: GarageStore
    @State private var searchText: String = ""
    @State private var tab: WishlistTab = .parts

    @State private var sheet: WishlistSheet? = nil

    var body: some View {
        NavigationStack {
            VStack {
                Picker("Type", selection: $tab) {
                    ForEach(WishlistTab.allCases) { t in
                        Text(t.rawValue).tag(t)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                List {
                    switch tab {
                    case .parts:
                        let items = filteredParts()
                        if items.isEmpty {
                            EmptyRow(message: "Aucune pièce en favoris")
                        } else {
                            ForEach(items, id: \.part.id) { ref in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(ref.part.name).font(.body)
                                        Text("Véhicule: \(ref.vehicleName)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                        if let link = ref.part.url, let url = URL(string: link) {
                                            Link("Lien", destination: url).font(.caption)
                                        }
                                    }
                                    Spacer()
                                    Text(ref.part.price.currencyString)
                                        .font(.headline)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    sheet = .editPart(vehicleID: ref.vehicleID, part: ref.part)
                                }
                                .swipeActions {
                                    Button {
                                        sheet = .editPart(vehicleID: ref.vehicleID, part: ref.part)
                                    } label: {
                                        Label("Modifier", systemImage: "pencil")
                                    }.tint(.orange)
                                    Button(role: .destructive) {
                                        if let vIdx = store.vehicles.firstIndex(where: { $0.id == ref.vehicleID }),
                                           let pIdx = store.vehicles[vIdx].wishlist.firstIndex(where: { $0.id == ref.part.id }) {
                                            store.deletePart(at: IndexSet(integer: pIdx), vehicleID: ref.vehicleID)
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                            }
                        }

                    case .listings:
                        let items = filteredListings()
                        if items.isEmpty {
                            EmptyRow(message: "Aucune annonce en favoris")
                        } else {
                            ForEach(items) { v in
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(v.name).font(.body)
                                        Text(v.price?.currencyString ?? "-")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    if let url = v.listingURL, let u = URL(string: url) {
                                        Link("Annonce", destination: u)
                                    }
                                }
                                .contentShape(Rectangle())
                                .onTapGesture { sheet = .editListing(v) }
                                .swipeActions {
                                    Button { sheet = .editListing(v) } label: {
                                        Label("Modifier", systemImage: "pencil")
                                    }.tint(.orange)
                                    Button(role: .destructive) {
                                        if let idx = store.toBuy.firstIndex(where: { $0.id == v.id }) {
                                            store.deleteToBuy(at: IndexSet(integer: idx))
                                        }
                                    } label: {
                                        Label("Supprimer", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
                .searchable(text: $searchText,
                            placement: .navigationBarDrawer(displayMode: .always),
                            prompt: tab == .parts ? "Rechercher une pièce" : "Rechercher une annonce")
            }
            .navigationTitle("Favoris")
        }
        .sheet(item: $sheet) { sheet in
            switch sheet {
            case .editPart(let vehicleID, let part):
                PartEditorView(existing: part) { updated in
                    store.updatePart(updated, vehicleID: vehicleID)
                }
                .presentationDetents([.medium])

            case .editListing(let item):
                PurchaseEditorView(existing: item) { updated in
                    store.updateVehicleToBuy(updated)
                }
                .presentationDetents([.medium, .large])
            }
        }
    }

    private func filteredParts() -> [(vehicleID: UUID, vehicleName: String, part: PartItem)] {
        let all: [(UUID, String, PartItem)] = store.vehicles.flatMap { v in
            v.wishlist.map { (v.id, v.name, $0) }
        }
        guard !searchText.isEmpty else { return all }
        return all.filter { (_, vName, p) in
            p.name.localizedCaseInsensitiveContains(searchText) ||
            (p.url ?? "").localizedCaseInsensitiveContains(searchText) ||
            vName.localizedCaseInsensitiveContains(searchText)
        }
    }

    private func filteredListings() -> [VehicleToBuy] {
        guard !searchText.isEmpty else { return store.toBuy }
        return store.toBuy.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.price?.currencyString ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }
}

private struct EmptyRow: View {
    let message: String
    var body: some View {
        Section {
            VStack(spacing: 10) {
                Image(systemName: "heart")
                    .font(.system(size: 40))
                    .foregroundStyle(.secondary)
                Text(message)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 28)
        }
        .listRowBackground(Color.clear)
    }
}
