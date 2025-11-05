//
//  PartEditorView.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI
import CarFuturePackage

struct PartEditorView: View {
    var onSave: (PartItem) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var url: String = ""
    @State private var price: Double?

    var body: some View {
        NavigationStack {
            Form {
                Section("Pièce") {
                    TextField("Nom", text: $name)
                    TextField("Lien (optionnel)", text: $url)
                        .keyboardType(.URL)
                    TextField("Prix", value: $price, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Nouvelle pièce")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        onSave(.init(name: name,
                                     url: url.isEmpty ? nil : url,
                                     price: price ?? 0))
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
