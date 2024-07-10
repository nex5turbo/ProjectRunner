//
//  ColorSheetButton.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/9/24.
//

import SwiftUI

struct ColorSheetButton<Content: View>: View {
    let onSelect: (MarkColor) -> Void
    let content: Content
    @State private var isColorSheetPresented: Bool = false
    init(onSelect: @escaping (MarkColor) -> Void, @ViewBuilder label: () -> Content) {
        self.onSelect = onSelect
        self.content = label()
    }
    var body: some View {
        Button {
            self.isColorSheetPresented.toggle()
        } label: {
            content
        }
        .sheet(isPresented: $isColorSheetPresented) {
            ColorSheet { color in
                onSelect(color)
            }
            .presentationDetents([.medium])
        }

    }
}

#Preview {
    ColorSheetButton { _ in
    } label: {
        
    }
}
