//
//  StartView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct StartView: View {
    private let transitionAction: () -> Void

    init(transitionAction: @escaping () -> Void) {
        self.transitionAction = transitionAction
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            VStack(spacing: 10) {
                LogomarkView()
                LogoTextView()
            }
            startButton
            Spacer()
        }
    }
}

private extension StartView {
    var startButton: some View {
        Button(
            action: {
                transitionAction()
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
