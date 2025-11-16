//
//  TabBarButtonView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct TabBarButtonView: View {
    private let buttonSize = CGSize(width: 70, height: 60)
    private let buttonCornerRadius: CGFloat = 4
    private let selectedButtonBorder: CGFloat = 3
    private let text: String
    private let isSelected: Bool

    private var textLengthWithoutNewlines: Int {
        text.filter { $0 != "\n" }.count
    }

    init(text: String, isSelected: Bool) {
        self.text = text
        self.isSelected = isSelected
    }

    var body: some View {
        ZStack {
            if isSelected {
                RoundedRectangle(cornerRadius: buttonCornerRadius + selectedButtonBorder)
                    .foregroundStyle(.yellow)
                    .frame(
                        width: buttonSize.width + selectedButtonBorder * 2,
                        height: buttonSize.height + selectedButtonBorder * 2
                    )
            }
            Text(text)
                .font(.system(size: 23, weight: .heavy))
                .lineSpacing(0)
                .scaleEffect(
                    x: textLengthWithoutNewlines > 5 ? 0.8 : 1.0,
                    anchor: .center
                )
                .foregroundStyle(.commonGreen)
                .frame(width: buttonSize.width, height: buttonSize.height)
                .background(
                    RadialGradient(
                        gradient: Gradient(stops: [
                            .init(color: .white, location: 0.0),
                            .init(color: .black, location: 1.0)
                        ]),
                        center: .center,
                        startRadius: 25,
                        endRadius: 200
                    )
                )
                .cornerRadius(buttonCornerRadius)
                .padding(isSelected ? 0 : selectedButtonBorder)
        }
    }
}

#Preview {
    HStack {
        TabBarButtonView(text: "差分\n検出", isSelected: true)
        TabBarButtonView(text: "コレク\nション", isSelected: false)
        TabBarButtonView(text: "環境\n設定", isSelected: false)
    }
}
