//
//  RMAppApp.swift
//  RMApp
//
//  Created by jorge Sanmartin on 20/11/22.
//

import SwiftUI

@main
struct RMAppApp: App {

    var body: some Scene {
        WindowGroup {
            HomeView(viewModel: HomeViewModel())
        }
    }
}
