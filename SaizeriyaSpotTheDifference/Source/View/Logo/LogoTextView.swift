//
//  LogoTextView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import SwiftUI

struct LogoTextView: View {
    var body: some View {
        VStack(spacing: 0) {
            topText
            bottomText
        }
    }
}

private extension LogoTextView {
    var topText: some View {
        Text("イタリアンファミレスの間違い探し")
            .font(.system(size: 17, weight: .regular))
            .foregroundColor(.commonGreen)
    }

    var bottomText: some View {
        Text("チートツール")
            .font(.system(size: 36, weight: .black))
            .foregroundColor(.commonRed)
    }
}
