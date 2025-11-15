//
//  TopView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct TopView: View {
    var body: some View {
        VStack {
            topBar
            Spacer()
            logo
            startButton
            Spacer()
            bottomBar
        }
    }
}

private extension TopView {
    var topBar: some View {
        Text("さあはじめましょう！")
            .font(.system(size: 20, weight: .bold))
            .foregroundStyle(.commonPrimary)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
            .background(.commonGreen)
    }

    var logo: some View {
        Image(systemName: "heart.fill")
    }

    var startButton: some View {
        Button(
            action: {},
            label: {
                Text("aaa")
            }
        )
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
    TopView()
}
