//
//  RootView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct RootView: View {
    @State private var selectedPage: Page = .start
    @State private var selectedTab: MainTab = .cheat
    @State private var topBarText: String = "答え合わせの時間だ！"

    var body: some View {
        VStack(spacing: 0) {
            topBar
            content
            bottomBar
        }
    }
}

private extension RootView {
    var topBar: some View {
        Text(topBarText)
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(.commonPrimary)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(.commonGreen)
            .transition(.opacity)
            .animation(.bouncy, value: topBarText)
    }

    var content: some View {
        ZStack {
            switch selectedPage {
            case .start:
                StartView(selectedPage: $selectedPage)
            case .main:
                MainView(
                    topBarText: $topBarText,
                    tab: selectedTab
                )
            }
        }
        .frame(maxHeight: .infinity)
        .transition(.opacity)
        .animation(.bouncy, value: selectedPage)
    }

    var bottomBar: some View {
        ZStack {
            switch selectedPage {
            case .start:
                Text("Let's spot the difference!")
                    .font(.system(size: 14))
                    .foregroundStyle(.commonPrimary)
                    .padding(.vertical, 4)
                    .transition(.opacity)
            case .main:
                HStack(spacing: 4) {
                    ForEach(Array(MainTab.allCases), id: \.self) { tab in
                        Button {
                            selectedTab = tab
                        } label: {
                            TabBarButtonView(
                                text: tab.text,
                                isSelected: tab == selectedTab
                            )
                        }
                    }
                }
                .padding(.vertical, 6)
                .transition(.opacity.animation(.easeInOut(duration: 0.3).delay(0.3)))
            }
        }
        .frame(maxWidth: .infinity)
        .background(.commonGreen)
        .animation(.bouncy, value: selectedPage)
    }
}

#Preview {
    RootView()
}
