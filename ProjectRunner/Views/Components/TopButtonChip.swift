//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/4/24.
//

import SwiftUI

struct TopButtonChip<Content: View>: View {
    let title: String
    let imageName: String
    let isSystem: Bool
    let content: Content
    init(title: String, imageName: String, isSystem: Bool, @ViewBuilder content: () -> Content) {
        self.title = title
        self.imageName = imageName
        self.isSystem = isSystem
        self.content = content()
    }
    private var imageColor: Color? = nil
    private var isSelected: Bool = false
    @State private var iconSize: CGFloat = 0
    var shouldFixWidth: Bool = true
    var body: some View {
        HStack {
            if imageName == "" {
               content
                    .frame(width: shouldFixWidth ? iconSize : nil, height: iconSize)
            } else {
                if isSystem {
                    if let imageColor {
                        Image(systemName: imageName)
                            .foregroundStyle(imageColor)
                            .font(.caption)
                    } else {
                        Image(systemName: imageName)
                            .foregroundStyle(isSelected ? .white : .black)
                            .font(.caption)
                    }
                } else {
                    Image(imageName)
                        .resizable()
                }
            }
            Text(title)
                .foregroundStyle(isSelected ? .white : .black)
                .font(.caption)
                .overlay {
                    GeometryReader { proxy in
                        Color.clear.task {
                            self.iconSize = proxy.size.height
                        }
                    }
                }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 8)
        .background(isSelected ? Color(UIColor.systemBlue) : .white)
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1),radius: 1, y: 1)
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray, lineWidth: 0.1)
        }
        .padding(.vertical, 8)

    }
    
    func isSelected(_ value: Bool) -> Self {
        var view = self
        view.isSelected = value
        
        return view
    }
    
    func fixedWidth() -> Self {
        var view = self
        view.shouldFixWidth = false
        
        return view
    }
    
    func setImageColor(_ value: Color) -> Self {
        var view = self
        view.imageColor = value
        return view
    }
}

#Preview {
    ContentView()
}
