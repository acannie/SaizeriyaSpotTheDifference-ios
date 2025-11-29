//
//  CollectionView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct CollectionView: View {
    @EnvironmentObject private var headerViewModel: HeaderViewModel

    var body: some View {
        Text("Collection")
            .onAppear {
                headerViewModel.updateText("集めた間違い探しを眺めよう")
            }
    }
}
