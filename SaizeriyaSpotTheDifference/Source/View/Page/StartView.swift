//
//  StartView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct StartView: View {
    @State private var startsAnimation: Bool = false
    @Binding private var selectedPage: Page

    init(selectedPage: Binding<Page>) {
        self._selectedPage = selectedPage
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 10) {
                LogomarkView()
                    .opacity(startsAnimation ? 0 : 1)
                    .offset(y: startsAnimation ? -150 : 0)
                    .animation(
                        .easeIn(duration: 0.3).delay(0.0),
                        value: startsAnimation
                    )
                LogoTextView()
                    .opacity(startsAnimation ? 0 : 1)
                    .offset(y: startsAnimation ? -150 : 0)
                    .animation(
                        .easeIn(duration: 0.3).delay(0.1),
                        value: startsAnimation
                    )
            }
            startButton
                .opacity(startsAnimation ? 0 : 1)
                .offset(y: startsAnimation ? -150 : 0)
                .animation(
                    .easeIn(duration: 0.3).delay(0.2),
                    value: startsAnimation
                )
            Spacer()
        }
    }
}

private extension StartView {
    var startButton: some View {
        Button(
            action: {
                Task {
                    startsAnimation = true
                    try! await Task.sleep(for: .seconds(0.7))
                    selectedPage = .main
                }
            }
        ) {
            RedButtonView(
                label: "間違い探しをはじめる",
                fontSize: 28
            )
        }
    }
}

#Preview {
    StartView(selectedPage: .constant(.start))
}
