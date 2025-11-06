//
//  AddVehicleView.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI
import PhotosUI
import CarFuturePackage

struct AddVehicleView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: GarageStore

    @State private var name = ""
    @State private var type: VehicleType = .car

    @State private var weight: Int?
    @State private var seats: Int?
    @State private var hp: Int?
    @State private var torque: Int?
    @State private var year: Int?

    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var photos: [PhotoAssetCarFuture] = []

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
            .navigationTitle("Ajouter un véhicule")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        let c = Characteristics(weightKg: weight, seats: seats, horsepower: hp, torqueNm: torque, year: year)
                        let v = Vehicle(type: type, name: name, photos: photos, characteristics: c, wishlist: [])
                        store.addVehicle(v)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .task(id: pickerItems) {
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
                    get: {
                        if let val = value.wrappedValue {
                            return String(val)
                        } else {
                            return ""
                        }
                    },
                    set: { newValue in
                        if let intVal = Int(newValue) {
                            value.wrappedValue = intVal
                        } else {
                            value.wrappedValue = nil
                        }
                    }
                )
            )
            .keyboardType(.numberPad)
            .multilineTextAlignment(.trailing)
            .frame(width: 100)
        }
    }

}
