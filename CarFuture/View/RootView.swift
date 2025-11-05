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
            GarageView()
                .tabItem {
                    Label("Garage", systemImage: "car.fill")
                }

            WishlistView()
                .tabItem {
                    Label("Wishlist", systemImage: "list.bullet.rectangle.portrait")
                }

            PurchasesView()
                .tabItem {
                    Label("Achat", systemImage: "cart.fill")
                }
        }
    }
}
