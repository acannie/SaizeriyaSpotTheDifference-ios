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
            topBar
            mainContent
            bottomBar
        }
        .navigationBarBackButtonHidden(true)
    }
}

private extension TopView {
    var topBar: some View {
        Text("ほげほげ")
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(.commonPrimary)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(.commonGreen)
    }

    var mainContent: some View {
        Group {
            switch selectedPage {
            case .cheat:
                CheatView()
            case .collection:
                CollectionView()
            case .environmentSetting:
                EnvironmentSettingView()
            }
        }
        .frame(maxHeight: .infinity)
    }

    var bottomBar: some View {
        HStack(spacing: 4) {
            ForEach(Page.allCases, id: \.self) { page in
                Button(
                    action: {
                        selectedPage = page
                    }
                ) {
                    TabBarButtonView(
                        text: page.rawValue,
                        isSelected: page == selectedPage
                    )
                }
            }
        }
        .padding(.vertical, 6)
        .frame(maxWidth: .infinity)
        .background(.commonGreen)
    }
}

#Preview {
    TopView()
}
