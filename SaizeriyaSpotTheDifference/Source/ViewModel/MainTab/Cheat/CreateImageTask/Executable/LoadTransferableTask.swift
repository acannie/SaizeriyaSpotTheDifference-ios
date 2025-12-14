//
//  LoadTransferableTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/30.
//

import UIKit
import PhotosUI
import SwiftUI

struct LoadTransferableTask: CreateImageTaskExecutable {
    let headerText: String = "画像を読み込み中"

    func process(from imageSuite: ImageSuite) async throws -> ImageSuite {
        guard case .photosPickerItem(let photosPickerItem) = imageSuite.processing else {
            throw CreateImageTaskError.unexpectedError
        }

        let cgImage = try await cgImage(from: photosPickerItem)

        return .init(
            processing: .single(.cg(cgImage)),
            preview: .single(.cg(cgImage)),
            result: nil
        )
    }
}

private extension LoadTransferableTask {
    func cgImage(from item: PhotosPickerItem) async throws -> CGImage {
        guard let data = try await item.loadTransferable(type: Data.self) else {
            throw CreateImageTaskError.couldnotReadImageData
        }

        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            throw CreateImageTaskError.couldnotReadImageData
        }

        guard let cgImage = CGImageSourceCreateImageAtIndex(source, 0, [
            kCGImageSourceShouldCache: true
        ] as CFDictionary) else {
            throw CreateImageTaskError.couldnotReadImageData
        }

        return cgImage
    }
}
