//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/4/24.
//

import SwiftUI

struct CountChip: View {
    let count: Int
    var body: some View {
//        Circle().fill(.red)
//            .frame(width: 24, height: 24)
//            .overlay {
//                Text("\(count)")
//                    .foregroundStyle(.white)
//                    .lineLimit(1)
//                    .font(.caption)
//                    .bold()
//            }
        Text("\(count)")
            .foregroundStyle(.gray.opacity(0.6))
            .lineLimit(1)
            .font(.title3)
    }
}

#Preview {
    ContentView()
}
