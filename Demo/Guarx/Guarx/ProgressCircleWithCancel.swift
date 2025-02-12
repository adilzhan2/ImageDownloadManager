//
//  ProgressCircleWithCancel.swift
//  GuarX
//
//  Created by Adilzhan Akhayev on 12.02.2025.
//

import SwiftUI

struct ProgressCircleWithCancel: View {
    let progress: Double
    let onCancel: () -> Void

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: progress)
                .stroke(.black, lineWidth: 6)
                .rotationEffect(.degrees(-90))
                .frame(width: 40, height: 40)

            Button(action: {
                onCancel()
            }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .foregroundColor(.black)
                    .frame(width: 30, height: 30)
            }
        }
    }
}
