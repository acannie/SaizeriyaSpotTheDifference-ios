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
        let diffImage1 = try await computeDifferenceTransparent(context: context, imageLeft: ciImageLeft, imageRight: ciImageRight)

        // ResultPayloadを作成
        guard case .double(let leftPreviewImage, _) = imageSuite.preview else {
            throw CreateImageTaskError.unexpectedError
        }
        let baseImage = leftPreviewImage

        return .init(
            processing: .differences([]),
            preview: imageSuite.preview,
            result: .init(
                baseImage: baseImage,
                leftImageDifferenceLayers: [],
                rightImageDifferenceLayers: []
            )
        )
    }
}

private extension DifferingPixelCoordinatesTask {
    func computeDifferenceTransparent(
        context: CIContext,
        imageLeft: CIImage,
        imageRight: CIImage
    ) async throws -> UIImage {
        // --- ① 軽くぼかす ---
        let blurRadius: CGFloat = 2.0
        let blurLeft = imageLeft.applyingFilter("CIGaussianBlur", parameters: ["inputRadius": blurRadius])
        let blurRight = imageRight.applyingFilter("CIGaussianBlur", parameters: ["inputRadius": blurRadius])

        // 1. difference blend
        let diffFilter = CIFilter.differenceBlendMode()
        diffFilter.inputImage = blurLeft
        diffFilter.backgroundImage = blurRight
        guard var diffOutput = diffFilter.outputImage else {
            throw CreateImageTaskError.unexpectedError
        }

        // 2. 黒(0,0,0) → 透明 に変換する
        let colorMatrix = CIFilter.colorMatrix()
        colorMatrix.inputImage = diffOutput

        // RGB はそのまま
        colorMatrix.rVector = CIVector(x: 1, y: 0, z: 0, w: 0)
        colorMatrix.gVector = CIVector(x: 0, y: 1, z: 0, w: 0)
        colorMatrix.bVector = CIVector(x: 0, y: 0, z: 1, w: 0)

        // アルファ値 = RGB の最大値（差分が大きいほど不透明）
        colorMatrix.aVector = CIVector(x: 1, y: 1, z: 1, w: 0)
        guard let transparentOutput = colorMatrix.outputImage else {
            throw CreateImageTaskError.unexpectedError
        }

        // 3. CGImage 化
        guard let cgimg = context.createCGImage(
            transparentOutput,
            from: transparentOutput.extent
        ) else {
            throw CreateImageTaskError.unexpectedError
        }
        return UIImage(cgImage: cgimg)
    }
}
