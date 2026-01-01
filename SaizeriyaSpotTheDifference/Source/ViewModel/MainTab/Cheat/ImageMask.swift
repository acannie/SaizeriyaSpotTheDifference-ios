//
//  ImageMask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/12/15.
//

struct ImageMask: Hashable {
    let coordinates: Set<PixelCoordinate>

    init(coordinates: Set<PixelCoordinate>) {
        self.coordinates = coordinates
    }

    init(regionSet: PixelRegionSet) {
        var coordinates: Set<PixelCoordinate> = []
        for region in regionSet.regions {
            coordinates.formUnion(region.coordinates)
        }
        self.coordinates = coordinates
    }

    func contains(coordinate: PixelCoordinate) -> Bool {
        coordinates.contains(coordinate)
    }
}
