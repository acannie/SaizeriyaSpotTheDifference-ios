//
//  CreateImageTaskError.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/20.
//

enum CreateImageTaskError: Error {
    case couldnotDetectMenuBook
    case unexpectedError

    var description: String {
        switch self {
        case .couldnotDetectMenuBook:
            "間違い探しを検出できませんでした"
        case .unexpectedError:
            "予期せぬエラーが発生しました"
        }
    }
}
