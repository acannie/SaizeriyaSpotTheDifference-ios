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
    case single(Image)
    case pair(ImagePair)
    case differences(Set<ImageCoordinate>)

    enum Image: Hashable {
        case cg(CGImage)
        case ci(CIImage)
    }

    enum ImagePair: Hashable {
        case cg(CGImage, CGImage)
        case ci(CIImage, CIImage)
    }
}
