//
//  ImageCoordinate.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/12/01.
//

struct ImageCoordinate: Hashable {
    let x: Int
    let y: Int

    func add(_ coordinate: ImageCoordinate) -> ImageCoordinate {
        .init(
            x: self.x + coordinate.x,
            y: self.y + coordinate.y
        )
    }
}
