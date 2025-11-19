//
//  SplitAndResizeTask.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

struct SplitAndResizeTask: CreateImageTaskExecutable {
    let headerText: String = "2枚の絵に分割中……"

    func createImage(from imageSuite: ImageSuite) async throws -> ImageSuite {
        try? await Task.sleep(for: .seconds(1))

        switch imageSuite {
        case .single(let image):
            return .double(left: image, right: image)
        case .double:
            throw CreateImageTaskError.unexpectedError
        }
    }
}
