//
//  PartEditorView.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//
import SwiftUI
import CarFuturePackage

struct PartEditorView: View {
    var existing: PartItem?
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
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                    TextField("Prix", value: $price, format: .number)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle(existing == nil ? "Nouvelle pièce" : "Modifier pièce")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(existing == nil ? "Ajouter" : "Enregistrer") {
                        let item = PartItem(
                            id: existing?.id ?? UUID(),
                            name: name,
                            url: url.isEmpty ? nil : url,
                            price: price ?? 0
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
                    url = existing.url ?? ""
                    price = existing.price
                }
            }
        }
    }
}
