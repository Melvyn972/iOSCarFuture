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

    var body: some View {
        NavigationStack {
            List {
                ForEach(store.toBuy) { v in
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
                }
                .onDelete(perform: store.deleteToBuy)
            }
            .navigationTitle("À acheter")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    StyledButton(title: "Ajouter", systemImage: "plus") {
                        showAdd = true
                    }
                }
            }
            .sheet(isPresented: $showAdd) {
                AddPurchaseView()
                    .presentationDetents([.medium, .large])
            }
        }
    }
}

private struct PurchaseDetailView: View {
    let item: VehicleToBuy
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PhotoGalleryView(images: item.photos.compactMap { $0.image })
                VehicleCard(
                    vehicleName: item.name,
                    subtitle: item.type.rawValue,
                    heroImage: item.photos.first?.image,
                    statLeft: ("Prix", item.price?.currencyString ?? "-"),
                    statRight: ("Année", item.characteristics.year.map(String.init) ?? "-")
                )
                .padding(.horizontal)

                GroupBox {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes").font(.headline)
                        Text(item.notes.isEmpty ? "—" : item.notes)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(item.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AddPurchaseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: GarageStore

    @State private var name = ""
    @State private var type: VehicleType = .car
    @State private var url: String = ""
    @State private var price: Double?
    @State private var year: Int?
    @State private var notes: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("Informations") {
                    TextField("Nom", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(VehicleType.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    TextField("Lien de l’annonce", text: $url)
                        .keyboardType(.URL)
                    TextField("Prix", value: $price, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Année", value: $year, format: .number)
                        .keyboardType(.numberPad)
                }
                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }
            }
            .navigationTitle("Ajouter un achat")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        let item = VehicleToBuy(
                            type: type,
                            name: name,
                            listingURL: url.isEmpty ? nil : url,
                            price: price,
                            photos: [],
                            notes: notes,
                            characteristics: .init(year: year),
                            plannedParts: []
                        )
                        store.addVehicleToBuy(item)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
