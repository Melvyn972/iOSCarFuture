//
//  PurchaseEditorView.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 05/11/2025.
//
import SwiftUI
import PhotosUI

struct PurchaseEditorView: View {
    var existing: VehicleToBuy?
    var onSave: (VehicleToBuy) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var type: VehicleType = .car
    @State private var url: String = ""
    @State private var price: Double?
    @State private var year: Int?
    @State private var notes: String = ""

    @State private var pickerItems: [PhotosPickerItem] = []
    @State private var photos: [PhotoAsset] = []

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
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    TextField("Prix", value: $price, format: .number)
                        .keyboardType(.decimalPad)
                    TextField("Année", value: $year, format: .number)
                        .keyboardType(.numberPad)
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 100)
                }

                Section("Photos") {
                    PhotosPicker(selection: $pickerItems, maxSelectionCount: 10, matching: .images) {
                        Label("Importer depuis la galerie", systemImage: "photo.badge.plus")
                    }

                    ScrollView(.horizontal) {
                        HStack(spacing: 12) {
                            ForEach(photos) { p in
                                ZStack(alignment: .topTrailing) {
                                    if let img = p.image {
                                        img.resizable()
                                            .scaledToFill()
                                            .frame(width: 100, height: 80)
                                            .clipShape(RoundedRectangle(cornerRadius: 8))
                                    } else {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(.ultraThinMaterial)
                                            .frame(width: 100, height: 80)
                                            .overlay {
                                                Image(systemName: "photo")
                                                    .foregroundStyle(.secondary)
                                            }
                                    }

                                    Button {
                                        if let idx = photos.firstIndex(of: p) {
                                            photos.remove(at: idx)
                                        }
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                            .symbolRenderingMode(.palette)
                                            .foregroundStyle(.white, .black.opacity(0.6))
                                    }
                                    .offset(x: 6, y: -6)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }
            }
            .navigationTitle(existing == nil ? "Ajouter un achat" : "Modifier l’annonce")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(existing == nil ? "Ajouter" : "Enregistrer") {
                        let item = VehicleToBuy(
                            id: existing?.id ?? UUID(),
                            type: type,
                            name: name,
                            listingURL: url.isEmpty ? nil : url,
                            price: price,
                            photos: photos,
                            notes: notes,
                            characteristics: .init(year: year),
                            plannedParts: existing?.plannedParts ?? []
                        )
                        onSave(item)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let existing {
                    name = existing.name
                    type = existing.type
                    url = existing.listingURL ?? ""
                    price = existing.price
                    year = existing.characteristics.year
                    notes = existing.notes
                    photos = existing.photos
                }
            }
            .task(id: pickerItems) {
                guard !pickerItems.isEmpty else { return }
                var loaded: [PhotoAsset] = photos
                for item in pickerItems {
                    if let data = try? await item.loadTransferable(type: Data.self) {
                        loaded.append(.init(data: data))
                    }
                }
                photos = loaded
                pickerItems = []
            }
        }
    }
}
