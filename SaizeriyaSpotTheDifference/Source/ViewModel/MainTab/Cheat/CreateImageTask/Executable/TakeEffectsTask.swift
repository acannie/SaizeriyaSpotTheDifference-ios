//
//  TakeEffectsTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

struct TakeEffectsTask: CreateImageTaskExecutable {
    let headerText: String = "撮影した写真を加工中……"

    func createImageSuite(from imageSuite: ImageSuite) async throws -> ImageSuite {
        try? await Task.sleep(for: .seconds(1))
        return imageSuite
    }
}
