//
//  PurchasesView.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI
import CarFuturePackage

struct PurchasesView: View {
    @EnvironmentObject private var store: GarageStore
    @State private var showAdd = false
    @State private var searchText = ""
    @State private var editing: VehicleToBuy? = nil

    var filtered: [VehicleToBuy] {
        guard !searchText.isEmpty else { return store.toBuy }
        return store.toBuy.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            ($0.price?.currencyString ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(filtered) { v in
                    NavigationLink {
                        PurchaseDetailView(item: v)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(v.name).font(.headline)
                            HStack(spacing: 8) {
                                if let price = v.price {
                                    Text(price.currencyString)
                                }
                                if let url = v.listingURL, let u = URL(string: url) {
                                    Link("Annonce", destination: u)
                                }
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                    .swipeActions {
                        Button {
                            editing = v
                        } label: {
                            Label("Modifier", systemImage: "pencil")
                        }
                        .tint(.orange)
                        Button(role: .destructive) {
                            if let idx = store.toBuy.firstIndex(where: { $0.id == v.id }) {
                                store.deleteToBuy(at: IndexSet(integer: idx))
                            }
                        } label: {
                            Label("Supprimer", systemImage: "trash")
                        }
                    }
                }
                .onDelete(perform: store.deleteToBuy)
            }
            .navigationTitle("À acheter")
            .searchable(text: $searchText, prompt: "Rechercher une annonce")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    StyledButton(title: "Ajouter", systemImage: "plus") {
                        showAdd = true
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                PurchaseEditorView { item in
                    store.addVehicleToBuy(item)
                }
                .presentationDetents([.medium, .large])
            }
            .sheet(item: $editing) { item in
                PurchaseEditorView(existing: item) { updated in
                    store.updateVehicleToBuy(updated)
                }
                .presentationDetents([.medium, .large])
            }
        }
    }
}

private struct PurchaseDetailView: View {
    @EnvironmentObject private var store: GarageStore
    @Environment(\.dismiss) private var dismiss

    let item: VehicleToBuy

    @State private var editing: VehicleToBuy? = nil
    @State private var confirmDelete = false

    private var currentItem: VehicleToBuy {
        store.toBuy.first(where: { $0.id == item.id }) ?? item
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PhotoGalleryView(images: currentItem.photos.compactMap { $0.image }, height: 320)

                VehicleCard(
                    vehicleName: currentItem.name,
                    subtitle: currentItem.type.rawValue,
                    heroImage: currentItem.photos.first?.image,
                    statLeft: ("Prix", currentItem.price?.currencyString ?? "-"),
                    statRight: ("Année", currentItem.characteristics.year.map(String.init) ?? "-"),
                    showHero: false
                )
                .padding(.horizontal)

                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes").font(.headline)
                        Text(currentItem.notes.isEmpty ? "—" : currentItem.notes)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)

                if let url = currentItem.listingURL, let u = URL(string: url) {
                    HStack {
                        Image(systemName: "link")
                        Link("Ouvrir l’annonce", destination: u)
                        Spacer()
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle(currentItem.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button {
                        editing = currentItem
                    } label: {
                        Label("Modifier l’annonce", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        confirmDelete = true
                    } label: {
                        Label("Supprimer", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .accessibilityLabel("Actions")
            }
        }
        .sheet(item: $editing) { it in
            PurchaseEditorView(existing: it) { updated in
                store.updateVehicleToBuy(updated)
            }
            .presentationDetents([.medium, .large])
        }
        .alert("Supprimer cette annonce ?", isPresented: $confirmDelete) {
            Button("Annuler", role: .cancel) {}
            Button("Supprimer", role: .destructive) {
                if let idx = store.toBuy.firstIndex(where: { $0.id == currentItem.id }) {
                    store.deleteToBuy(at: IndexSet(integer: idx))
                    dismiss()
                }
            }
        } message: {
            Text("Cette action est irréversible.")
        }
    }
}
