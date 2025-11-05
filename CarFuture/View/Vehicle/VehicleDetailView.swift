//
//  VehicleDetailView.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI
import CarFuturePackage

struct VehicleDetailView: View {
    @EnvironmentObject private var store: GarageStore
    @State private var showAddPart = false

    let vehicle: Vehicle

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                PhotoGalleryView(images: vehicle.photos.compactMap { $0.image })

                VehicleCard(
                    vehicleName: vehicle.name,
                    subtitle: vehicle.type.rawValue,
                    heroImage: vehicle.photos.first?.image,
                    statLeft: ("CV", vehicle.characteristics.horsepower.map(String.init) ?? "-"),
                    statRight: ("Kg", vehicle.characteristics.weightKg.map(String.init) ?? "-")
                )
                .padding(.horizontal)

                characteristicsSection

                wishlistSection
            }
        }
        .navigationTitle(vehicle.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                StyledButton(title: "Ajouter pièce", systemImage: "plus") {
                    showAddPart = true
                }
            }
        }
        .sheet(isPresented: $showAddPart) {
            PartEditorView { part in
                store.addPart(part, to: vehicle.id)
            }
            .presentationDetents([.medium])
        }
    }

    private var characteristicsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Caractéristiques")
                .font(.title2).bold()
                .padding(.horizontal)

            GroupBox {
                VStack(alignment: .leading, spacing: 8) {
                    charRow("Poids", vehicle.characteristics.weightKg.map { "\($0) kg" })
                    charRow("Places", vehicle.characteristics.seats.map(String.init))
                    charRow("Chevaux", vehicle.characteristics.horsepower.map { "\($0) cv" })
                    charRow("Couple", vehicle.characteristics.torqueNm.map { "\($0) Nm" })
                    charRow("Année", vehicle.characteristics.year.map(String.init))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
        }
    }

    private func charRow(_ label: String, _ value: String?) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value ?? "-")
        }
    }

    private var wishlistSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Wishlist")
                    .font(.title2).bold()
                Spacer()
                Text(vehicle.wishlistTotal.currencyString)
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            GroupBox {
                if let idx = store.vehicles.firstIndex(where: { $0.id == vehicle.id }) {
                    List {
                        ForEach(store.vehicles[idx].wishlist) { part in
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
                        .onDelete { offsets in
                            store.deletePart(at: offsets, vehicleID: vehicle.id)
                        }
                    }
                    .frame(minHeight: 100, idealHeight: 240, maxHeight: .infinity)
                    .listStyle(.plain)
                } else {
                    Text("Erreur: véhicule introuvable.")
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal)
        }
    }
}

