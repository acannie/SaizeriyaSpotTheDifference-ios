//
//  CGRect+.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/22.
//

import UIKit

extension CGRect {
    /// 反転させたサイズを返す
    var switched: CGRect {
        .init(x: minY, y: minX, width: height, height: width)
    }
}
