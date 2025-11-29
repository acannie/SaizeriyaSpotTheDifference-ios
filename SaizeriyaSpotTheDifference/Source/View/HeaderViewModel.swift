//
//  HeaderViewModel.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/17.
//

import SwiftUI
import Combine

final class HeaderViewModel: ObservableObject {
    @Published private(set) var text: String = "答え合わせの時間だ！"
    @Published private(set) var isLoading: Bool = false

    func updateText(_ text: String, isLoading: Bool = false) {
        self.text = text
        self.isLoading = isLoading
    }
}
