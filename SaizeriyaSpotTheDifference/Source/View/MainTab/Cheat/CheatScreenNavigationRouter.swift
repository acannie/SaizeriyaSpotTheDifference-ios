//
//  CheatScreenNavigationRouter.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/17.
//

import SwiftUI
import Combine

class CheatScreenNavigationRouter: ObservableObject {
    @Published var path = [Key]()

    enum Key: Hashable {
        case shooting
        case result(UIImage)

        @ViewBuilder
        func destination() -> some View {
            switch self {
            case .shooting:
                ShootingScreenView()
            case .result(let image):
                CheatResultScreenView(image: image)
            }
        }
    }
}
