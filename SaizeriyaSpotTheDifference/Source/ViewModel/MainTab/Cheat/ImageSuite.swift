//
//  ImageSuite.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

import UIKit
import _PhotosUI_SwiftUI

enum ImageSuite: Hashable {
    case photosPickerItem(PhotosPickerItem)
    case single(UIImage)
    case double(left: UIImage, right: UIImage)
}
