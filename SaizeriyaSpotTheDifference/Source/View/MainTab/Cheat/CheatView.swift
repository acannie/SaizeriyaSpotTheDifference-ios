//
//  CheatView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct CheatView: View {
    @StateObject private var navigationRouter = CheatScreenNavigationRouter()

    var body: some View {
        NavigationStack(path: $navigationRouter.path) {
            ShootingScreenView()
                .navigationDestination(
                    for: CheatScreenNavigationRouter.ScreenKey.self,
                    destination: { screenKey in
                        screenKey.destination()
                    }
                )
        }
        .environmentObject(navigationRouter)
    }
}
