//
//  TopView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct TopView: View {
    private enum Page: String, CaseIterable {
        case cheat = "差分検出"
        case collection = "コレクション"
        case environmentSetting = "環境設定"
    }
    @State private var selectedPage: Page = .cheat

    var body: some View {
        VStack(spacing: 0) {
            switch selectedPage {
            case .cheat:
                Text("CHEAT")
            case .collection:
                Text("コレクション")
            case .environmentSetting:
                Text("環境設定")
            }
            HStack {
                ForEach(Page.allCases, id: \.self) { page in
                    Button(
                        action: {
                            selectedPage = page
                        }
                    ) {
                        Text(page.rawValue)
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    TopView()
}
