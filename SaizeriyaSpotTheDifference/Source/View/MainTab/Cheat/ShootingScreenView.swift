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
            guard let image = camera.capturedImage else {
                return
            }
            let cropped = cropImage(image)
            self.navigationRouter.path.append(.result(cropped))
        }
        .onAppear {
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

    func cropImage(_ image: UIImage) -> UIImage {
        // プレビューと画像のサイズ比率
        let scale = image.size.width / UIScreen.main.bounds.width

        // x座標は0
        let originX: CGFloat = 0

        // y座標を計算
        let headerHeight = layoutHeight.headerHeight
        let contentHeight = layoutHeight.contentHeight
        let cameraPreviewHeight = contentHeight - footerHeight
        let originY = headerHeight

        // トリミング開始地点
        let cropRect = CGRect(
            x: originX * scale,
            y: originY * scale,
            width: UIScreen.main.bounds.width * scale,
            height: cameraPreviewHeight * scale
        )

        guard let result = image.cropping(to: cropRect) else {
            return UIImage()
        }
        return result
    }
}

extension UIImage.Orientation {
    /// 画像が横向きであるか
    var isLandscape: Bool {
        switch self {
        case .up, .down, .upMirrored, .downMirrored:
            false
        case .left, .right, .leftMirrored, .rightMirrored:
            true
        @unknown default:
            false
        }
    }
}

extension CGRect {
    /// 反転させたサイズを返す
    var switched: CGRect {
        .init(x: minY, y: minX, width: height, height: width)
    }
}

extension UIImage {
    func cropping(to rect: CGRect) -> UIImage? {
        let croppingRect: CGRect = imageOrientation.isLandscape ? rect.switched : rect
        guard let cgImage: CGImage = self.cgImage?.cropping(to: croppingRect) else {
            return nil
        }
        return UIImage(cgImage: cgImage, scale: scale, orientation: imageOrientation)
    }
}
