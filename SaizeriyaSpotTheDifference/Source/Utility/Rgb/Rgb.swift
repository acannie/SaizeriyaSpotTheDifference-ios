//
//  Rgb.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/25.
//

import Foundation

struct Rgb {
    let r: CGFloat
    let g: CGFloat
    let b: CGFloat

    var hex: String {
        let r255 = Int(self.r * 255)
        let g255 = Int(self.g * 255)
        let b255 = Int(self.b * 255)
        return String(format: "#%02X%02X%02X", r255, g255, b255)
    }

    func distance(from otherRgb: Rgb) -> CGFloat {
        let r2 = pow(self.r - otherRgb.r, 2)
        let g2 = pow(self.g - otherRgb.g, 2)
        let b2 = pow(self.b - otherRgb.b, 2)
        return sqrt(r2 + g2 + b2)
    }
}
