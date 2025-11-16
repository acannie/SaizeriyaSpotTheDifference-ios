//
//  CheatView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct CheatView: View {
    @Binding private var topBarText: String
    @State private var image: UIImage?

    init(topBarText: Binding<String>) {
        self._topBarText = topBarText
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Text("カメラを準備中です。そのまましばらくお待ちください。")
                CameraView(image: $image)
                Rectangle()
                    .stroke(.white, lineWidth: 2)
                    .frame(width: 200, height: 100)
            }
        }
        .onAppear {
            topBarText = "間違い探しを撮影しよう"
        }
    }
}
