//
//  UIImage+.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/22.
//

import UIKit

extension UIImage {
    var normalized: UIImage {
        if imageOrientation == .up {
            return self
        }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(in: CGRect(origin: .zero, size: size))
        let normalized = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return normalized
    }

    func cropping(to rect: CGRect) -> UIImage? {
        let croppingRect = imageOrientation.isLandscape ? rect.switched : rect
        guard let cgImage = self.cgImage?.cropping(to: croppingRect) else {
            return nil
        }
        return .init(
            cgImage: cgImage,
            scale: scale,
            orientation: imageOrientation
        )
    }
}

extension UIImage.Orientation {
    /// 画像が横向きであるか
    var isLandscape: Bool {
        switch self {
        case .up, .down, .upMirrored, .downMirrored:
            false
        case .left, .right, .leftMirrored, .rightMirrored:
            true
        @unknown default:
            false
        }
    }

    var cgImagePropertyOrientation: CGImagePropertyOrientation {
        switch self {
        case .up: .up
        case .down: .down
        case .left: .left
        case .right: .right
        case .upMirrored: .upMirrored
        case .downMirrored: .downMirrored
        case .leftMirrored: .leftMirrored
        case .rightMirrored: .rightMirrored
        @unknown default: .up
        }
    }
}
