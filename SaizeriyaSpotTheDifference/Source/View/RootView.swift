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
    @StateObject private var headerViewModel = HeaderViewModel()
    private let headerHeight: CGFloat = 36
    private let startPageFooterHeight: CGFloat = 24
    private let mainPageFooterHeight: CGFloat = 72
    private var contentHeight: CGFloat {
        safeScreenHeight - headerHeight - mainPageFooterHeight
    }
    private var safeScreenHeight: CGFloat {
        let window = UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .first { $0.isKeyWindow }
        let topInset = window?.safeAreaInsets.top ?? 0
        let bottomInset = window?.safeAreaInsets.bottom ?? 0
        return UIScreen.main.bounds.height - topInset - bottomInset
    }

    var body: some View {
        VStack(spacing: 0) {
            header
            content
            footer
        }
    }
}

private extension RootView {
    var header: some View {
        let dotWidth: CGFloat = 5
        let dotPadding: CGFloat = 5
        var dotsWidth: CGFloat {
            (dotWidth + dotPadding * 2) * 3
        }
        return HStack(spacing: 0) {
            Text(headerViewModel.text)
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.commonPrimary)
            if headerViewModel.isLoading {
                HStack(spacing: 0) {
                    ForEach(0..<3, id: \.self) { count in
                        Circle()
                            .foregroundStyle(.commonPrimary)
                            .frame(width: dotWidth)
                            .padding(.horizontal, dotPadding)
                    }
                    Spacer(minLength: 0)
                }
                .frame(width: dotsWidth)
            }
        }
        .frame(height: headerHeight)
        .frame(maxWidth: .infinity)
        .background(.commonGreen)
    }

    var content: some View {
        ZStack {
            switch selectedPage {
            case .start:
                StartView(selectedPage: $selectedPage)
            case .main:
                MainView(tab: selectedTab)
                    .environmentObject(headerViewModel)
                    .environment(
                        \.layoutHeight,
                        .init(
                            headerHeight: headerHeight,
                            contentHeight: contentHeight,
                            footerHeight: mainPageFooterHeight
                        )
                    )
            }
        }
        .frame(maxHeight: .infinity)
        .transition(.opacity)
        .animation(.bouncy, value: selectedPage)
    }

    var footer: some View {
        ZStack {
            switch selectedPage {
            case .start:
                Text("Let's spot the difference!")
                    .font(.system(size: 14))
                    .foregroundStyle(.commonPrimary)
                    .frame(height: startPageFooterHeight)
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
                .frame(height: mainPageFooterHeight)
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
