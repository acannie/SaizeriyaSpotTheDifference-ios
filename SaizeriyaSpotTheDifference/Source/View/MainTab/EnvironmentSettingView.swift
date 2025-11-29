//
//  EnvironmentSettingView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct EnvironmentSettingView: View {
    @EnvironmentObject private var headerViewModel: HeaderViewModel

    var body: some View {
        Text("EnvironmentSetting")
            .onAppear {
                headerViewModel.updateText("アプリの詳細はこちら")
            }
    }
}
