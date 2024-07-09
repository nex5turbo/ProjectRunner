//
//  CircleName.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/9/24.
//

import SwiftUI

struct CircleName: View {
    let markColor: MarkColor
    let text: String
    init(markColor: MarkColor, text: String) {
        self.markColor = markColor
        self.text = text
    }
    
    private var circleSize: CGFloat = 100
    private var paddingValue: CGFloat {
        circleSize * (32 / 180)
    }

    var body: some View {
        let newText = text.trimmingCharacters(in: .whitespaces).prefix(2)
        let color = getColor()
        Circle()
            .fill(LinearGradient(colors: [color.opacity(0.6), color.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing))
            .frame(width: circleSize, height: circleSize)
            .overlay {
                if !newText.isEmpty {
                    let string = String(newText)
                    Text(string.uppercased())
                        .font(.system(size: 300))
                        .minimumScaleFactor(0.01)
                        .foregroundStyle(.white)
                        .padding(paddingValue)
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: circleSize - paddingValue, height: circleSize - paddingValue)
                        .clipShape(Circle())
                        .clipped()
                        .foregroundStyle(.white)
                }
            }
            .clipped()
    }
    
    func setCircleSize(_ value: CGFloat = 30) -> Self {
        var view = self
        view.circleSize = value
        return view
    }
    
    private func getColor() -> Color {
        return markColor == .noColor ? .gray : markColor.color
    }
}

#Preview {
    ContentView()
}
