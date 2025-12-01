//
//  Lab.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/12/02.
//

import CoreGraphics
import Foundation

struct Lab {
    let l: CGFloat
    let a: CGFloat
    let b: CGFloat

    init(_ rgb: Rgb) {
        // 0-255 → 0-1
        let rs = rgb.r / 255.0
        let gs = rgb.g / 255.0
        let bs = rgb.b / 255.0

        // sRGB → Linear RGB
        func toLinear(_ c: CGFloat) -> CGFloat {
            return c <= 0.04045 ? c / 12.92 : pow((c + 0.055) / 1.055, 2.4)
        }

        let rLin = toLinear(rs)
        let gLin = toLinear(gs)
        let bLin = toLinear(bs)

        // Linear RGB → XYZ（D65）
        let X = (0.4124 * rLin + 0.3576 * gLin + 0.1805 * bLin) * 100
        let Y = (0.2126 * rLin + 0.7152 * gLin + 0.0722 * bLin) * 100
        let Z = (0.0193 * rLin + 0.1192 * gLin + 0.9505 * bLin) * 100

        // XYZ → Lab
        func f(_ t: CGFloat) -> CGFloat {
            return t > pow(6.0/29.0, 3.0)
            ? pow(t, 1.0/3.0)
            : (1.0/3.0) * pow(29.0/6.0, 2.0) * t + 4.0/29.0
        }

        let xn: CGFloat = 95.047
        let yn: CGFloat = 100.000
        let zn: CGFloat = 108.883

        let fx = f(X / xn)
        let fy = f(Y / yn)
        let fz = f(Z / zn)

        self.l = 116 * fy - 16
        self.a = 500 * (fx - fy)
        self.b = 200 * (fy - fz)
    }

    /// ΔE（Lab距離）
    func deltaE(from other: Self) -> CGFloat {
        let dL = self.l - other.l
        let da = self.a - other.a
        let db = self.b - other.b
        return sqrt(dL * dL + da * da + db * db)
    }
}
