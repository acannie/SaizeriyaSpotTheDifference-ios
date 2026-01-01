//
//  PixelRegionSet.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/12/31.
//

struct PixelRegionSet: Hashable {
    private(set) var regions: Set<PixelRegion> = []

    init(regions: Set<PixelRegion>) {
        self.regions = regions
    }

    mutating func insert(_ region: PixelRegion) {
        regions.insert(region)
    }

    func coordinates() -> Set<PixelCoordinate> {
        var coordinates: Set<PixelCoordinate> = []
        for region in regions {
            coordinates.formUnion(region.coordinates)
        }
        return coordinates
    }
}
