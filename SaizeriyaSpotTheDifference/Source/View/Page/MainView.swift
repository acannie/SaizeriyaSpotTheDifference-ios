//
//  MainView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct MainView: View {
    private let tab: MainTab

    init(tab: MainTab) {
        self.tab = tab
    }

    var body: some View {
        switch tab {
        case .cheat:
            CheatView()
        case .collection:
            CollectionView()
        case .environmentSetting:
            EnvironmentSettingView()
        }
    }
}
