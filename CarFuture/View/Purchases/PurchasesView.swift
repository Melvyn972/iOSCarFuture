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
            Group {
                if filtered.isEmpty {
                    emptyState
                } else {
                    List {
                        ForEach(filtered) { v in
                            NavigationLink {
                                PurchaseDetailView(item: v)
                            } label: {
                                PurchaseRowCard(v: v)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
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
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
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
            .background {
                LinearGradient(
                    colors: [
                        Color(uiColor: .systemBackground),
                        Color(uiColor: .secondarySystemBackground)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 88, height: 88)
                Image(systemName: "cart.badge.plus")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            .overlay {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .stroke(.white.opacity(0.1), lineWidth: 1)
            }

            Text("Aucune annonce")
                .font(.title3.weight(.semibold))

            Text("Ajoutez une annonce pour suivre vos futurs achats.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            StyledButton(title: "Ajouter une annonce", systemImage: "plus") {
                showAdd = true
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

private struct PurchaseRowCard: View {
    let v: VehicleToBuy

    var body: some View {
        HStack(spacing: 12) {
            thumb
                .frame(width: 56, height: 56)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 0.8)
                        .blendMode(.overlay)
                }

            VStack(alignment: .leading, spacing: 6) {
                Text(v.name)
                    .font(.headline)
                    .lineLimit(1)

                HStack(spacing: 8) {
                    if let price = v.price?.currencyString {
                        Pill(systemImage: "tag", text: price)
                    }
                    if let url = v.listingURL, let u = URL(string: url) {
                        LinkPill(systemImage: "link", text: "Annonce", url: u)
                    }
                }
                .lineLimit(1)
            }

            Spacer()
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(accentGradient.opacity(0.10).blendMode(.plusLighter))
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(.white.opacity(0.10), lineWidth: 1)
                }
        }
        .contentShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .hoverEffect(.highlight)
        .accessibilityElement(children: .combine)
    }

    private var thumb: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.regularMaterial)

            if let img = v.photos.first?.image {
                img
                    .resizable()
                    .scaledToFill()
                    .clipped()
            } else {
                Image(systemName: "car.fill")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var accentGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color.accentColor.opacity(0.25),
                Color.accentColor.opacity(0.05)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

private struct Pill: View {
    let systemImage: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: systemImage)
                .imageScale(.small)
                .foregroundStyle(.secondary)
            Text(text)
                .font(.footnote.weight(.semibold))
                .monospacedDigit()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            Capsule(style: .continuous)
                .fill(.thinMaterial)
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(.white.opacity(0.08), lineWidth: 0.8)
                        .blendMode(.overlay)
                }
        }
    }
}

private struct LinkPill: View {
    let systemImage: String
    let text: String
    let url: URL

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .imageScale(.small)
                    .foregroundStyle(.secondary)
                Text(text)
                    .font(.footnote.weight(.semibold))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background {
                Capsule(style: .continuous)
                    .fill(.thinMaterial)
                    .overlay {
                        Capsule(style: .continuous)
                            .strokeBorder(.white.opacity(0.08), lineWidth: 0.8)
                            .blendMode(.overlay)
                    }
            }
        }
        .buttonStyle(.plain)
    }
}

private struct PurchaseDetailView: View {
    @EnvironmentObject private var store: GarageStore
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL

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
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Notes")
                            .font(.headline)
                        Text(currentItem.notes.isEmpty ? "—" : currentItem.notes)
                            .font(.body)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 2)
                }
                .padding(.horizontal)

                if let url = currentItem.listingURL, let u = URL(string: url) {
                    HStack(spacing: 12) {
                        Button {
                            openURL(u)
                        } label: {
                            Label("Ouvrir l’annonce", systemImage: "arrow.up.right.square")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.borderedProminent)

                        ShareLink(item: u) {
                            Label("Partager", systemImage: "square.and.arrow.up")
                                .font(.subheadline.weight(.semibold))
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 24)
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
