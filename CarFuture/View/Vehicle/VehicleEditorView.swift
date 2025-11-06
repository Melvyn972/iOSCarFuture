//
//  VehicleEditorView.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 05/11/2025.
//
import SwiftUI
import PhotosUI
import CarFuturePackage

struct VehicleEditorView: View {
    let vehicle: Vehicle
    var onSave: (Vehicle) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var type: VehicleType
    @State private var weight: Int?
    @State private var seats: Int?
    @State private var hp: Int?
    @State private var torque: Int?
    @State private var year: Int?
    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var photos: [PhotoAssetCarFuture]

    init(vehicle: Vehicle, onSave: @escaping (Vehicle) -> Void) {
        self.vehicle = vehicle
        self.onSave = onSave
        _name = State(initialValue: vehicle.name)
        _type = State(initialValue: vehicle.type)
        _weight = State(initialValue: vehicle.characteristics.weightKg)
        _seats = State(initialValue: vehicle.characteristics.seats)
        _hp = State(initialValue: vehicle.characteristics.horsepower)
        _torque = State(initialValue: vehicle.characteristics.torqueNm)
        _year = State(initialValue: vehicle.characteristics.year)
        _photos = State(initialValue: vehicle.photos)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Informations") {
                    TextField("Nom du véhicule", text: $name)
                    Picker("Type", selection: $type) {
                        ForEach(VehicleType.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                }

                Section("Caractéristiques") {
                    numberRow("Poids (kg)", value: $weight)
                    numberRow("Places", value: $seats)
                    numberRow("Chevaux (CV)", value: $hp)
                    numberRow("Couple (Nm)", value: $torque)
                    numberRow("Année", value: $year)
                }

                Section("Photos") {
                    PhotosPicker(selection: $pickerItems, maxSelectionCount: 10, matching: .images) {
                        Label("Importer depuis la galerie", systemImage: "photo.badge.plus")
                    }
                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(photos) { p in
                                if let img = p.image {
                                    img
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 80)
                                        .clipShape(RoundedRectangle(cornerRadius: 8))
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle("Modifier le véhicule")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Enregistrer") {
                        let c = Characteristics(weightKg: weight, seats: seats, horsepower: hp, torqueNm: torque, year: year)
                        let updated = Vehicle(
                            id: vehicle.id,
                            type: type,
                            name: name,
                            photos: photos,
                            characteristics: c,
                            wishlist: vehicle.wishlist
                        )
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .task(id: pickerItems) {
                guard !pickerItems.isEmpty else { return }
                var loaded: [PhotoAssetCarFuture] = []
                for item in pickerItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        loaded.append(.init(data: data))
                    }
                }
                photos = loaded
            }
        }
    }

    private func numberRow(_ title: String, value: Binding<Int?>) -> some View {
        HStack {
            Text(title)
            Spacer()
            TextField(
                "",
                text: Binding(
                    get: { value.wrappedValue.map(String.init) ?? "" },
                    set: { newValue in value.wrappedValue = Int(newValue) }
                )
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .frame(width: 100)
        }
    }
}
