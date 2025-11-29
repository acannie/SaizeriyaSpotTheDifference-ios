//
//  CrestView.swift
//  SaizeriyaSpotTheDifference
//
//  Created by SASAOKA Akane on 2025/11/30.
//

import SwiftUI

struct CrestView: View {
    let color: Color
    let backgroundColor: Color

    var body: some View {
        ZStack {
            Group {
                Ellipse()
                    .trim(from: 0.0, to: 0.5)
                    .fill(color)
                Ellipse()
                    .stroke(color, lineWidth: 1)
            }
            .frame(width: 35, height: 40)
            ForEach(Side.allCases, id: \.self) { side in
                Image(systemName: "crown.fill")
                    .resizable()
                    .foregroundStyle(color)
                    .frame(width: 15, height: 5)
                    .rotationEffect(.degrees(side.unit * 15))
                    .offset(x: side.unit * 5)
            }
            .offset(y: -24)
            ForEach(Side.allCases, id: \.self) { side in
                Image(systemName: side.isLeft ? "laurel.leading" : "laurel.trailing")
                    .resizable()
                    .fontWeight(.black)
                    .foregroundStyle(color)
                    .frame(width: 10, height: 30)
                    .rotationEffect(.degrees(side.unit * 20))
                    .offset(x: side.unit * 20, y: 10)
            }
            Group {
                Image(systemName: "book.fill")
                    .resizable()
                    .foregroundStyle(backgroundColor)
                    .frame(width: 20, height: 15)
                Image(systemName: "book")
                    .resizable()
                    .foregroundStyle(color)
                    .frame(width: 19, height: 14)
            }
            .offset(x: -4, y: 0)
            Group {
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .fontWeight(.black)
                    .foregroundStyle(backgroundColor)
                    .frame(width: 16, height: 16)
                Image(systemName: "magnifyingglass")
                    .resizable()
                    .foregroundStyle(color)
                    .frame(width: 14, height: 14)
            }
            .offset(x: 7, y: 7)
            Image(systemName: "questionmark")
                .resizable()
                .foregroundStyle(color)
                .frame(width: 5, height: 8)
                .offset(y: -13)
        }
    }
}
