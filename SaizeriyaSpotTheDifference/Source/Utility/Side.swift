//
//  Side.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/16.
//

import Foundation

enum Side: CaseIterable {
    case left
    case right

    var unit: CGFloat {
        switch self {
        case .left: -1
        case .right: 1
        }
    }

    var isLeft: Bool {
        self == .left
    }
}
