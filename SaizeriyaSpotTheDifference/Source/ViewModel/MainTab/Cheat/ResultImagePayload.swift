//
//  ResultImagePayload.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/30.
//

import UIKit

struct ResultImagePayload {
    let baseImage: CGImage
    let leftImageDifferenceLayers: [CGImage]
    let rightImageDifferenceLayers: [CGImage]
}
