//
//  CGImage+.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/12/16.
//

import CoreGraphics

extension CGImage {
    func extractPixels(at coordinates: Set<PixelCoordinate>) async throws -> CGImage {
        let baseImageRgbGrid = try await RgbGrid(self)

        var rgbRows: [[Rgb]] = []
        for y in 0..<self.height {
            var row: [Rgb] = []
            for x in 0..<self.width {
                let coordinate = PixelCoordinate(x: x, y: y)
                if coordinates.contains(coordinate) {
                    row.append(baseImageRgbGrid.pixel(x, y))
                } else {
                    row.append(.init(r: 0, g: 0, b: 0))
                }
            }
            rgbRows.append(row)
        }
        let rgbGrid = try RgbGrid(rgbRows)
        return try rgbGrid.makeCGImage()
    }
}
