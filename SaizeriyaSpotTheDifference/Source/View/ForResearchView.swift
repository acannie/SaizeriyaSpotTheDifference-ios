//
//  ForResearchView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/12.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ForResearchView: View {
    var originalImageWidth: CGFloat {
        (UIScreen.main.bounds.width - 30) / 2
    }

    var body: some View {
        VStack {
            HStack {
                Image("test_pair_202510_left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: originalImageWidth)
                Image("test_pair_202510_right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: originalImageWidth)
            }
            // ここに差分を表示
        }
        .onAppear {
            // ここで差分を計算
        }
    }
}
