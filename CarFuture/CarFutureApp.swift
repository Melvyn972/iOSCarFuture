//
//  CarFutureApp.swift
//  CarFuture
//
//  Created by THIERRY-BELLEFOND Melvyn on 04/11/2025.
//

import SwiftUI

@main
struct CarFutureApp: App {
    @StateObject private var store = GarageStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(store)
        }
    }
}
