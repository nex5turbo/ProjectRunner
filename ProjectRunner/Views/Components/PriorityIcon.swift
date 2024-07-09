//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/6/24.
//

import SwiftUI

struct PriorityIcon: View {
    let priority: Priority
    init(priority: Priority) {
        self.priority = priority
    }

    var body: some View {
        ZStack {
            switch priority {
            case .urgent:
                Color(red: 1.0, green: 0.33, blue: 0.33) // 부드러운 빨강
            case .high:
                Color(red: 1.0, green: 0.59, blue: 0.20) // 부드러운 주황
            case .medium:
                Color(red: 1.0, green: 0.85, blue: 0.35) // 부드러운 노랑
            case .low:
                Color(red: 0.47, green: 0.72, blue: 0.47)
            case .none:
                Color(red: 0.26, green: 0.66, blue: 0.84)
            }
            Group {
                switch priority {
                case .urgent:
                    Text("5")
                case .high:
                    Text("4")
                case .medium:
                    Text("3")
                case .low:
                    Text("2")
                case .none:
                    Text("1")
                }
            }
            .font(.footnote)
            .foregroundStyle(.white)
        }
        .cornerRadius(4)
        .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
    }
}

#Preview {
    PriorityIcon(priority: .high)
}
