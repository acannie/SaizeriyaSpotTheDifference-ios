//
//  CheatResultScreenView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/18.
//

import SwiftUI

struct CheatResultScreenView: View {
    @EnvironmentObject private var headerViewModel: HeaderViewModel
    @EnvironmentObject private var navigationRouter: CheatScreenNavigationRouter
    let image: UIImage

    var body: some View {
        VStack {
            Text("Cheat Result Screen View")
            Image(uiImage: image)
                .resizable()
                .frame(maxWidth: UIScreen.main.bounds.width - 20)
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            headerViewModel.updateText("間違いを検出中……")
        }
    }
}
