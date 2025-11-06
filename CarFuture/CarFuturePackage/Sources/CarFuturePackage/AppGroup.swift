//
//  AppGroup.swift
//  CarFuturePackage
//
//  Created by THIERRY-BELLEFOND Melvyn on 06/11/2025.
//


import Foundation

public enum AppGroup {
    public static let identifier = "group.com.melvyn.carfuture"

    public static var containerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier)
    }
}
