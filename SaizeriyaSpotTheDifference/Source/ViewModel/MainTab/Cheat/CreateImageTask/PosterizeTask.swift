//
//  PosterizeTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/25.
//

import UIKit

struct PosterizeTask: CreateImageTaskExecutable {
    let headerText: String = "ポスタライズ加工中……"

    func createImageSuite(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .single(let uiImage) = imageSuite,
              let cgImage = uiImage.cgImage else {
            throw CreateImageTaskError.unexpectedError
        }

        // 画像の形式変換
        let context = CIContext()
        let ciImage = CIImage(cgImage: cgImage)

        // ポスタライズ処理
        let posterizedCiImage = await ciImage.posterize()

        // 返却値の作成
        let resultCgImage = try posterizedCiImage.createCgImage(with: context)
        let resultImage = UIImage(
            cgImage: resultCgImage,
            scale: uiImage.scale,
            orientation: uiImage.imageOrientation
        )

        return .single(resultImage)
    }
}

private extension CIImage {
    /// 四角形補正済みの写真から、元イラストに近い塗り分けを抽出する
    /// - Parameters:
    ///   - image: 入力 UIImage（四角形補正済み）
    ///   - medianRadius: Median フィルタの強さ（ノイズ吸収）
    ///   - blurRadius: BoxBlur の半径（アンチエイリアス吸収）
    ///   - posterizeLevels: Posterize の階調数（少なめで1色化を強める）
    /// - Returns: 処理後 UIImage
    func posterize(
       medianRadius: Double = 1.0,
       blurRadius: Double = 1.0,
       posterizeLevels: Float = 4.0
    ) async -> CIImage {
        let context = CIContext()
        var ciImage = self

        // ===== Step 1: Median Filter で微細ノイズ吸収 =====
        if let median = CIFilter(name: "CIMedianFilter") {
            median.setValue(ciImage, forKey: kCIInputImageKey)
            ciImage = median.outputImage ?? ciImage
        }

        // ===== Step 2: BoxBlur でアンチエイリアス・境界の揺れを吸収 =====
        if let boxBlur = CIFilter(name: "CIBoxBlur") {
            boxBlur.setValue(ciImage, forKey: kCIInputImageKey)
            boxBlur.setValue(3.0, forKey: kCIInputRadiusKey) // 1〜2px
            ciImage = boxBlur.outputImage ?? ciImage
        }

        // ===== Step 3: Posterize で階調を揃えて近似1色化 =====
//        if let poster = CIFilter(name: "CIColorPosterize") {
//            poster.setValue(ciImage, forKey: kCIInputImageKey)
//            poster.setValue(5.0, forKey: "inputLevels") // 4〜5程度
//            ciImage = poster.outputImage ?? ciImage
//        }

        // ===== Step 4: Lab -> RGB に戻す（近似） =====
        if let labToRGB = CIFilter(name: "CIColorMatrix") {
            let convertRGBToLabFilter = CIFilter.convertRGBtoLab()
            convertRGBToLabFilter.inputImage = ciImage
            convertRGBToLabFilter.normalize = true
            return convertRGBToLabFilter.outputImage!
        }

        // ===== Step 5: UIImage に変換して返す =====
        return ciImage
    }
}
