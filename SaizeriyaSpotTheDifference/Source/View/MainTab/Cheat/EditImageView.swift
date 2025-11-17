//
//  EditImageView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/17.
//

import SwiftUI

struct EditImageView: View {
    @EnvironmentObject private var navigationRouter: CheatScreenNavigationRouter
    let image: UIImage

    var body: some View {
        VStack {
            Text("Edit Image View")
            Image(uiImage: image)
                .resizable()
                .frame(maxWidth: UIScreen.main.bounds.width - 20)
        }
        .navigationBarBackButtonHidden(true)
    }
}
