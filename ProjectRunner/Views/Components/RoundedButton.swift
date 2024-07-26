//
//  RoundedButton.swift
//  PhotoRoad
//
//  Created by 워뇨옹 on 6/19/24.
//

import SwiftUI

struct RoundedButton: View {
    private let action: () -> Void
    private let text: String
    private let caption: String?
    
    private var enabled: Bool = true
    private var bgColor: Color = .white
    private var fgColor: Color = .black
    private var isInfinity: Bool = true
    private var cornerRadius: CGFloat = 10
    init(_ text: String, caption: String? = nil, action: @escaping () -> Void) {
        self.action = action
        self.text = text
        self.caption = caption
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack {
                Text(text)
                    .font(.title2)
                    .foregroundStyle(fgColor)
                if let caption {
                    Text(caption)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .frame(maxWidth: isInfinity ? .infinity : nil)
            .background(bgColor)
            .cornerRadius(cornerRadius)
            .padding(.horizontal)
        }
    }
    
    func bgColor(_ color: Color) -> Self {
        var view = self
        view.bgColor = color
        return view
    }
    
    func fgColor(_ color: Color) -> Self {
        var view = self
        view.fgColor = color
        return view
    }
}

#Preview {
    ContentView()
}
