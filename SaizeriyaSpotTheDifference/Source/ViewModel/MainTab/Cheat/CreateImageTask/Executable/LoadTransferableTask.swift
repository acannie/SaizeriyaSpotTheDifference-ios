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

        guard let data = try await photosPickerItem.loadTransferable(type: Data.self),
              let uiImage = UIImage(data: data) else {
            throw CreateImageTaskError.couldnotReadImageData
        }

        return .init(
            processing: .single(uiImage),
            preview: .single(uiImage),
            result: nil
        )
    }
}
