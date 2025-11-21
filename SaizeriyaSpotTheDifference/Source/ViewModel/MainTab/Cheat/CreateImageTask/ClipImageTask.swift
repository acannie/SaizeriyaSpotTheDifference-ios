//
//  ClipImageTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

import UIKit
import AVFoundation

struct ClipImageTask: CreateImageTaskExecutable {
    let layoutHeight: LayoutHeight
    let cameraPreviewFooterHeight: CGFloat
    var headerText: String = "撮影範囲を計算中……"

    func createImageSuite(from imageSuite: ImageSuite) async throws -> ImageSuite {
        try? await Task.sleep(for: .seconds(1.0))

        guard case .single(let image) = imageSuite else {
            throw CreateImageTaskError.unexpectedError
        }

        // プレビューと画像のサイズ比率
        let scale = image.size.width / UIScreen.main.bounds.width

        // x座標は0
        let originX: CGFloat = 0

        // y座標を計算
        let headerHeight = layoutHeight.headerHeight
        let contentHeight = layoutHeight.contentHeight
        let cameraPreviewHeight = contentHeight - cameraPreviewFooterHeight
        let originY = headerHeight

        // トリミング開始地点
        let cropRect = CGRect(
            x: originX * scale,
            y: originY * scale,
            width: UIScreen.main.bounds.width * scale,
            height: cameraPreviewHeight * scale
        )

        guard let croppedImage = image.cropping(to: cropRect) else {
            throw CreateImageTaskError.unexpectedError
        }
        return .single(croppedImage)
    }
}
