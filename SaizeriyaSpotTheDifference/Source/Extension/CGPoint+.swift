//
//  CGPoint+.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/22.
//

import UIKit

extension CGPoint {
    func distance(to point: Self) -> CGFloat {
        hypot(self.x - point.x, self.y - point.y)
    }

    func toImagePoint(size: CGSize) -> Self {
        .init(
            x: self.x * size.width,
            y: self.y * size.height
        )
    }
}
