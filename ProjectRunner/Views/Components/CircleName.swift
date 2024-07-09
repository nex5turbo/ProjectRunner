//
//  CircleName.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/9/24.
//

import SwiftUI

struct CircleName: View {
    var id: String = UUID().uuidString
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
        ZStack {
            Circle()
                .fill(.white)
                .frame(width: circleSize, height: circleSize)
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

struct CircleNames: View {

    var views: [CircleName]
    
    init(views: [CircleName]) {
        self.views = views
    }
    var body: some View {
        ZStack {
            ForEach(0..<min(views.count, 3), id: \.self) { index in
                views[index]
                    .scaleEffect((100 - (CGFloat(2 - index) * 3)) / 100)
                    .offset(x: CGFloat(index) * 3)
            }
        }
    }
}

#Preview {
    ContentView()
}
