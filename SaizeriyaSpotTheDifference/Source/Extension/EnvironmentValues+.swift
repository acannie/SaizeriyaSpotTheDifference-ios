//
//  EnvironmentValues+.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/21.
//

import SwiftUI

extension EnvironmentValues {
    var layoutHeight: LayoutHeight {
        get { self[LayoutHeightKey.self] }
        set { self[LayoutHeightKey.self] = newValue }
    }
}
