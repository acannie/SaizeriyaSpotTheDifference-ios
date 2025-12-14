//
//  PixelCoordinate.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/12/01.
//

struct PixelCoordinate: Hashable {
    let x: Int
    let y: Int

    func add(_ coordinate: PixelCoordinate) -> PixelCoordinate {
        .init(
            x: self.x + coordinate.x,
            y: self.y + coordinate.y
        )
    }
}
