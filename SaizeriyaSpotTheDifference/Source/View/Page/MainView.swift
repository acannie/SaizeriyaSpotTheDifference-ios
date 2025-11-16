//
//  MainView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct MainView: View {
    @Binding private var topBarText: String
    private let tab: MainTab

    init(topBarText: Binding<String>, tab: MainTab) {
        self._topBarText = topBarText
        self.tab = tab
    }

    var body: some View {
        switch tab {
        case .cheat:
            CheatView(topBarText: $topBarText)
        case .collection:
            CollectionView()
        case .environmentSetting:
            EnvironmentSettingView()
        }
    }
}
