//
//  RedButtonView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct RedButtonView: View {
    private let label: String
    private let fontSize: CGFloat

    init(
        label: String,
        fontSize: CGFloat = 17
    ) {
        self.label = label
        self.fontSize = fontSize
    }

    var body: some View {
        Text(label)
            .font(.system(size: fontSize, weight: .semibold))
            .foregroundStyle(.commonPrimary)
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        stops: [
                            .init(color: .buttonRedBackgroundTop, location: 0.0),
                            .init(color: .buttonRedBackgroundBottom, location: 0.3),
                            .init(color: .buttonRedBackgroundBottom, location: 1.0)
                        ]
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.buttonRedBorder, lineWidth: 2)
            )
    }
}
