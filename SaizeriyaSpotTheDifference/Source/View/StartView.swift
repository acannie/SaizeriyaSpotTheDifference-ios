//
//  StartView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct StartView: View {
    var body: some View {
        VStack(spacing: 32) {
            topBar
            Spacer()
            VStack(spacing: 10) {
                LogomarkView()
                LogoTextView()
            }
            startButton
            Spacer()
            bottomBar
        }
    }
}

private extension StartView {
    var topBar: some View {
        Text("答え合わせの時間だ！")
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(.commonPrimary)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(.commonGreen)
    }

    var startButton: some View {
        NavigationLink(destination: Text("aaa")) {
            RedButtonView(
                label: "間違い探しをはじめる",
                fontSize: 28
            )
        }
    }

    var bottomBar: some View {
        Text("Let's spot the difference!")
            .font(.system(size: 14))
            .foregroundStyle(.commonPrimary)
            .padding(.vertical, 4)
            .frame(maxWidth: .infinity)
            .background(.commonGreen)
    }
}

#Preview {
    StartView()
}
