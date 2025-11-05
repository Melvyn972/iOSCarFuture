//
//  GarageView.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI
import PhotosUI
import CarFuturePackage

struct GarageView: View {
    @EnvironmentObject private var store: GarageStore
    @State private var showAdd = false
    @State private var searchText = ""
    @State private var editing: Vehicle? = nil

    var filtered: [Vehicle] {
        guard !searchText.isEmpty else { return store.vehicles }
        return store.vehicles.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private let grid = [GridItem(.adaptive(minimum: 160), spacing: 16)]

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: grid, spacing: 16) {
                    ForEach(filtered) { v in
                        NavigationLink {
                            VehicleDetailView(vehicle: v)
                        } label: {
                            VehicleCard(
                                vehicleName: v.name,
                                subtitle: v.type.rawValue,
                                heroImage: v.photos.first?.image,
                                statLeft: ("CV", v.characteristics.horsepower.map(String.init) ?? "-"),
                                statRight: ("Kg", v.characteristics.weightKg.map(String.init) ?? "-")
                            )
                            .contentShape(Rectangle())
                        }
                        .contextMenu {
                            Button {
                                editing = v
                            } label: {
                                Label("Modifier", systemImage: "pencil")
                            }
                            Button(role: .destructive) {
                                if let idx = store.vehicles.firstIndex(where: { $0.id == v.id }) {
                                    store.deleteVehicles(at: IndexSet(integer: idx))
                                }
                            } label: {
                                Label("Supprimer", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Mon Garage")
            .searchable(text: $searchText,
                        placement: .navigationBarDrawer(displayMode: .always),
                        prompt: "Rechercher un véhicule")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    StyledButton(title: "Ajouter", systemImage: "plus") {
                        showAdd = true
                    }
                    .accessibilityIdentifier("addVehicleButton")
                }
            }
            .sheet(isPresented: $showAdd) {
                AddVehicleView()
                    .presentationDetents([.medium, .large])
            }
            .sheet(item: $editing) { item in
                VehicleEditorView(vehicle: item) { updated in
                    store.updateVehicle(updated)
                }
                .presentationDetents([.large])
            }
        }
    }
}
