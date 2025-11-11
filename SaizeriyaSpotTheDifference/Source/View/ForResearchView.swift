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

        let diffFilter = CIFilter.differenceBlendMode()
        diffFilter.inputImage = ciLeft
        diffFilter.backgroundImage = ciRight

        if let diffOutput = diffFilter.outputImage,
           let cgimg = context.createCGImage(diffOutput, from: diffOutput.extent) {
            diffImage = UIImage(cgImage: cgimg)
        }
    }
}
