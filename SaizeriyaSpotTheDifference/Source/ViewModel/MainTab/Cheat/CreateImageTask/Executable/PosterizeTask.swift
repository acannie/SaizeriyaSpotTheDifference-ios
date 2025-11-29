//
//  PosterizeTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/25.
//

import UIKit

struct PosterizeTask: CreateImageTaskExecutable {
    let headerText: String = "ポスタライズ加工中"

    func createImageSuite(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .single(let uiImage) = imageSuite,
              let cgImage = uiImage.cgImage else {
            throw CreateImageTaskError.unexpectedError
        }

        // 画像の形式変換
        let context = CIContext()
        var ciImage = CIImage(cgImage: cgImage)

        // ポスタライズ処理
        ciImage = try await ciImage.posterize()
        ciImage = try await ciImage.median()
        ciImage = try await ciImage.noiseReduction()
        let palette = try await ciImage.kMeans()
        ciImage = try await ciImage.palettize(paletteImage: palette.settingAlphaOne(in: palette.extent))

        // 返却値の作成
        let resultCgImage = try ciImage.createCgImage(with: context)
        let resultImage = UIImage(
            cgImage: resultCgImage,
            scale: uiImage.scale,
            orientation: uiImage.imageOrientation
        )

        return .single(resultImage)
    }
}

private extension CIImage {
    /// 明るさ・コントラスト調整
    func colorControls() async throws -> CIImage {
        let colorControlsFilter = CIFilter.colorControls()
        colorControlsFilter.inputImage = self
        colorControlsFilter.brightness = 0.1
        colorControlsFilter.contrast = 0.9
        return colorControlsFilter.outputImage!
    }

    /// Median Filter で微細ノイズ吸収
    func median() async throws -> CIImage {
        let median = CIFilter.median()
        median.inputImage = self
        return median.outputImage!
    }

    /// ノイズ除去
    func noiseReduction() async throws -> CIImage {
        let noise = CIFilter.noiseReduction()
        noise.inputImage = self
        noise.noiseLevel = 0.06   // 0.01〜0.05 推奨
        noise.sharpness  = 1.5    // 0.3〜0.5
        return noise.outputImage!
    }

    /// Posterize で階調を揃えて近似1色化
    func posterize() async throws -> CIImage {
        guard let poster = CIFilter(name: "CIColorPosterize") else {
            throw CreateImageTaskError.unexpectedError
        }
        poster.setValue(self, forKey: kCIInputImageKey)
        poster.setValue(3.5, forKey: "inputLevels") // 4〜5程度
        return poster.outputImage!
    }

    /// パレットを作る
    func kMeans() async throws -> CIImage {
        let kMeansFilter = CIFilter.kMeans()
        kMeansFilter.inputImage = self
        kMeansFilter.extent = self.extent
        kMeansFilter.count = 30
        kMeansFilter.passes = 20
        kMeansFilter.perceptual = false
        return kMeansFilter.outputImage!
    }

    /// パレットを元に色を分類した画像を作成する
    func palettize(paletteImage: CIImage) async throws -> CIImage {
        let palettize = CIFilter.palettize()
        palettize.inputImage = self
        palettize.paletteImage = paletteImage
        palettize.perceptual = true
        return palettize.outputImage!
    }

    /// BoxBlur でアンチエイリアス・境界の揺れを吸収
    func boxBlur() async throws -> CIImage {
        guard let boxBlurFilter = CIFilter(name: "CIBoxBlur") else {
            throw CreateImageTaskError.unexpectedError
        }
        boxBlurFilter.setValue(self, forKey: kCIInputImageKey)
        boxBlurFilter.setValue(3.0, forKey: kCIInputRadiusKey) // 1〜2px
        return boxBlurFilter.outputImage!
    }
}
