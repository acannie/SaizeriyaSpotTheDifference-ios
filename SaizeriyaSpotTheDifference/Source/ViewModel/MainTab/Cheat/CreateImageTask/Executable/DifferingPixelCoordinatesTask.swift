//
//  DifferingPixelCoordinatesTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

import UIKit

// 精度を確認するための仮実装
struct DifferingPixelCoordinatesTask: CreateImageTaskExecutable {
    let headerText: String = "差分を検出中"

    func process(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .double(let left, let right) = imageSuite.processing,
              let cgImageLeft = left.cgImage,
              let cgImageRight = right.cgImage else {
            throw CreateImageTaskError.unexpectedError
        }

        // 画像の形式変換
        let context = CIContext()
        let ciImageLeft = CIImage(cgImage: cgImageLeft)
        let ciImageRight = CIImage(cgImage: cgImageRight)

        // ポスタライズ処理
        let diffImage1 = try await computeDifference1(context: context, imageLeft: ciImageLeft, imageRight: ciImageRight)

        return .init(
            processing: .single(diffImage1),
            preview: imageSuite.preview,
            result: nil
        )
    }
}

private extension DifferingPixelCoordinatesTask {
    func computeDifference1(
        context: CIContext,
        imageLeft: CIImage,
        imageRight: CIImage
    ) async throws -> UIImage {
        let diffFilter = CIFilter.differenceBlendMode()
        diffFilter.inputImage = imageLeft
        diffFilter.backgroundImage = imageRight
        let diffOutput = diffFilter.outputImage!

        let cgimg = try diffOutput.createCgImage(with: context)
        let diffImage = UIImage(cgImage: cgimg)
        return diffImage
    }
}
