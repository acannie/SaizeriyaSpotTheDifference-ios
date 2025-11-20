//
//  LayoutHeight.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/21.
//

import SwiftUI

struct LayoutHeight {
    let headerHeight: CGFloat
    let contentHeight: CGFloat
    let footerHeight: CGFloat
}

struct LayoutHeightKey: EnvironmentKey {
    static let defaultValue = LayoutHeight(
        headerHeight: 0,
        contentHeight: 0,
        footerHeight: 0
    )
}
