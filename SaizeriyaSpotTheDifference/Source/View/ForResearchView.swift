//
//  ForResearchView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/12.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

struct ForResearchView: View {
    @State private var diffImage: UIImage? = nil
    private let context = CIContext()

    var originalImageWidth: CGFloat {
        (UIScreen.main.bounds.width - 30) / 2
    }

    var body: some View {
        VStack {
            HStack {
                Image("test_pair_202510_left")
                    .resizable()
                    .scaledToFit()
                    .frame(width: originalImageWidth)
                Image("test_pair_202510_right")
                    .resizable()
                    .scaledToFit()
                    .frame(width: originalImageWidth)
            }

            if let diff = diffImage {
                Text("差分プレビュー")
                    .font(.headline)
                    .padding(.top, 8)
                Image(uiImage: diff)
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width - 40)
                    .padding(.top, 4)
            } else {
                ProgressView("計算中…")
                    .padding(.top, 12)
            }
        }
        .onAppear {
            computeDifference()
        }
    }

    private func computeDifference() {
        guard
            let left = UIImage(named: "test_pair_202510_left"),
            let right = UIImage(named: "test_pair_202510_right"),
            let ciLeft = CIImage(image: left),
            let ciRight = CIImage(image: right)
        else { return }

        // --- ① 軽くぼかす ---
        let blurRadius: CGFloat = 2.0
        let blurLeft = ciLeft.applyingFilter("CIGaussianBlur", parameters: ["inputRadius": blurRadius])
        let blurRight = ciRight.applyingFilter("CIGaussianBlur", parameters: ["inputRadius": blurRadius])

        // --- ② 差分 ---
        let diffFilter = CIFilter.differenceBlendMode()
        diffFilter.inputImage = blurLeft
        diffFilter.backgroundImage = blurRight
        guard var diffOutput = diffFilter.outputImage else { return }

        // --- ③ 明暗を極端に強調（しきい値風） ---
        let controls = CIFilter.colorControls()
        controls.inputImage = diffOutput
        controls.saturation = 0.0    // モノクロ化
        controls.contrast = 5.0      // コントラストを強く
        controls.brightness = 0.3
        diffOutput = controls.outputImage ?? diffOutput

        // --- ④ 小さなノイズをぼかして除去（任意） ---
        diffOutput = diffOutput.applyingFilter("CIGaussianBlur", parameters: ["inputRadius": 0.5])

        // --- ⑤ 出力 ---
        if let cgimg = context.createCGImage(diffOutput, from: diffOutput.extent) {
            diffImage = UIImage(cgImage: cgimg)
        }
    }

}
