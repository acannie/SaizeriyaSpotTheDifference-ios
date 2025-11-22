//
//  ShootingScreenView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/17.
//

import SwiftUI
import AVFoundation

struct ShootingScreenView: View {
    @Environment(\.layoutHeight) private var layoutHeight
    @EnvironmentObject private var headerViewModel: HeaderViewModel
    @EnvironmentObject private var navigationRouter: CheatScreenNavigationRouter
    @StateObject private var camera = CameraManager()
    @State private var enableShootingButton: Bool = true
    private let footerHeight: CGFloat = 130
    private let guideLineWidth: CGFloat = 2
    private var guideLineSize: CGSize {
        let horizontalPadding: CGFloat = 10
        let width = UIScreen.main.bounds.width - horizontalPadding * 2
        let height = width / 2
        return .init(width: width, height: height)
    }

    var body: some View {
        ZStack {
            CameraPreview(session: camera.session)
            VStack {
                Spacer()
                guideLine
                Spacer()
                footer
            }
        }
        .onChange(of: camera.capturedImage) {
            if let image = camera.capturedImage {
                self.navigationRouter.path.append(
                    .result(
                        image,
                        cameraPreviewFooterHeight: footerHeight
                    )
                )
            }
        }
        .onAppear {
            enableShootingButton = true
            headerViewModel.updateText("間違い探しを撮影しよう")
        }
    }
}

private extension ShootingScreenView {
    var footer: some View {
        HStack {
            shootingButton
        }
        .frame(height: footerHeight)
        .frame(maxWidth: .infinity)
        .background(.cameraBackground)
    }

    var shootingButton: some View {
        Button(
            action: {
                enableShootingButton = false
                camera.takePhoto()
            }
        ) {
            ZStack {
                Circle()
                    .fill(.shutterButtonOutline)
                    .frame(width: 90, height: 90)
                Circle()
                    .fill(.shutterButtonFill)
                    .frame(width: 75, height: 75)
            }
            .shadow(radius: 4)
        }
        .disabled(!enableShootingButton)
    }

    var guideLine: some View {
        ZStack {
            // 枠
            Rectangle()
                .stroke(.cameraGuideLine, lineWidth: guideLineWidth)
                .frame(width: guideLineSize.width, height: guideLineSize.height)
            // 中央の線
            Rectangle()
                .fill(.cameraGuideLine)
                .frame(width: guideLineWidth, height: guideLineSize.height - guideLineWidth)
        }
    }
}
