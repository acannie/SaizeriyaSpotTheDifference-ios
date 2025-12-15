//
//  PixelRegion.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/12/15.
//

struct PixelRegion: Hashable {
    private(set) var coordinates: Set<PixelCoordinate> = []

    mutating func insert(_ coordinate: PixelCoordinate) {
        coordinates.insert(coordinate)
    }

    var isEmpty: Bool {
        coordinates.isEmpty
    }

    var size: Int {
        coordinates.count
    }
}
