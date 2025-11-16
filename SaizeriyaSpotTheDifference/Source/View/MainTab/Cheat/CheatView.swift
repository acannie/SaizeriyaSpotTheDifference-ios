//
//  CheatView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct CheatView: View {
    @Binding private var topBarText: String

    init(topBarText: Binding<String>) {
        self._topBarText = topBarText
    }

    var body: some View {
        Text("cheat")
            .onAppear {
                topBarText = "間違い探しを撮影しよう"
            }
    }
}
