//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/7/24.
//

import SwiftUI

struct PremiumButton<Content: View>: View {
    let action: () -> Void
    let content: Content
    
    init(action: @escaping () -> Void, @ViewBuilder label: () -> Content) {
        self.action = action
        self.content = label()
    }
    var body: some View {
        Button {
            action()
        } label: {
            content
        }

    }
}

struct PremiumNavigationLink<Content: View>: View {
    let destination: Content
    let content: Content
    
    init(@ViewBuilder destination: () -> Content, @ViewBuilder label: () -> Content) {
        self.destination = destination()
        self.content = label()
    }
    var body: some View {
        NavigationLink {
            destination
        } label: {
            content
        }

    }
}

#Preview {
    ContentView()
}
