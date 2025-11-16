//
//  StartView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct StartView: View {
    @State private var shouldOpenMain = false
    private let transitionAction: () -> Void

    init(transitionAction: @escaping () -> Void) {
        self.transitionAction = transitionAction
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 10) {
                LogomarkView()
                    .opacity(shouldOpenMain ? 0 : 1)
                    .offset(y: shouldOpenMain ? -150 : 0)
                    .animation(
                        .easeIn(duration: 0.3).delay(0.0),
                        value: shouldOpenMain
                    )
                LogoTextView()
                    .opacity(shouldOpenMain ? 0 : 1)
                    .offset(y: shouldOpenMain ? -150 : 0)
                    .animation(
                        .easeIn(duration: 0.3).delay(0.1),
                        value: shouldOpenMain
                    )
            }
            startButton
                .opacity(shouldOpenMain ? 0 : 1)
                .offset(y: shouldOpenMain ? -150 : 0)
                .animation(
                    .easeIn(duration: 0.3).delay(0.2),
                    value: shouldOpenMain
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
                    shouldOpenMain = true
                    try! await Task.sleep(for: .seconds(0.7))
                    transitionAction()
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
    StartView {}
}
