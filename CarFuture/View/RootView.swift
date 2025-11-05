//
//  RootView.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//

import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            NavigationStack {
                GarageView()
                    .navigationTitle("Garage")
            }
            .tabItem {
                Label("Garage", systemImage: "car.fill")
            }

            NavigationStack {
                WishlistView()
                    .navigationTitle("Favoris")
            }
            .tabItem {
                Label("Favoris", systemImage: "list.bullet.rectangle.portrait")
            }

            NavigationStack {
                PurchasesView()
                    .navigationTitle("Achats")
            }
            .tabItem {
                Label("Achat", systemImage: "cart.fill")
            }
        }
        .background(.ultraThinMaterial)
    }
}
