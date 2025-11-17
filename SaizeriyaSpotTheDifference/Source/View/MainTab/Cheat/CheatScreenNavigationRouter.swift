//
//  CheatScreenNavigationRouter.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/17.
//

import SwiftUI
import Combine

class CheatScreenNavigationRouter: ObservableObject {
    @Published var path = [ScreenKey]()

    enum ScreenKey: Hashable {
        case camera
        case confirm(UIImage)
        case result

        @ViewBuilder
        func destination() -> some View {
            switch self {
            case .camera:
                ShootingScreenView()
            case .confirm(let image):
                EditImageView(image: image)
            case .result:
                Text("Result")
            }
        }
    }
}
