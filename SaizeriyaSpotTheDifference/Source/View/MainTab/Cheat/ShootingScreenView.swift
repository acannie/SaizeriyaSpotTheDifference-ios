//
//  ShootingScreenView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/17.
//

import SwiftUI
import AVFoundation
import PhotosUI

struct ShootingScreenView: View {
    @Environment(\.layoutHeight) private var layoutHeight
    @EnvironmentObject private var headerViewModel: HeaderViewModel
    @EnvironmentObject private var navigationRouter: CheatScreenNavigationRouter
    @StateObject private var camera = CameraManager()
    @State private var enableShootingButton: Bool = true
    @State private var photosPickerItem: PhotosPickerItem?
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
                        .single(image),
                        from: .camera,
                        cameraPreviewFooterHeight: footerHeight
                    )
                )
            }
        }
        .onChange(of: photosPickerItem) {
            if let photosPickerItem {
                enableShootingButton = false
                Task {
                    // モーダルが閉じるまで待ってから画面遷移する
                    try? await Task.sleep(for: .seconds(0.5))
                    self.navigationRouter.path.append(
                        .result(
                            .photosPickerItem(photosPickerItem),
                            from: .photoPicker,
                            cameraPreviewFooterHeight: footerHeight
                        )
                    )
                }
            }
        }
        .onAppear {
            enableShootingButton = true
            headerViewModel.updateText("間違い探しを撮影しよう")
            camera.startRunning()
        }
        .onDisappear {
            photosPickerItem = nil
            camera.stopRunning()
        }
    }
}

private extension ShootingScreenView {
    var footer: some View {
        ZStack {
            HStack {
                pickerButton
                    .padding(.leading, 16)
                Spacer()
            }
            shootingButton
        }
        .frame(height: footerHeight)
        .frame(maxWidth: .infinity)
        .background(.cameraBackground)
    }

    var pickerButton: some View {
        PhotosPicker(
            selection: $photosPickerItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                Circle()
                    .fill(.shutterButtonOutline)
                    .frame(width: 52, height: 52)
                Image(systemName: "photo")
                    .resizable()
                    .foregroundStyle(.cameraBackground)
                    .scaledToFit()
                    .frame(width: 36)
            }
        }
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
