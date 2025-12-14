//
//  ImageSuite.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

import UIKit
import _PhotosUI_SwiftUI

enum ImagePayload: Hashable {
    case photosPickerItem(PhotosPickerItem)
    case singleCiImage(CIImage)
    case singleCgImage(CGImage)
    case doubleCiImage(left: CIImage, right: CIImage)
    case doubleCgImage(left: CGImage, right: CGImage)
    case differences(Set<ImageCoordinate>)
}
