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
    let reason: String
    
    @State private var isAlertPresented: Bool = false
    
    init(reason: String, action: @escaping () -> Void, @ViewBuilder label: () -> Content) {
        self.reason = reason
        self.action = action
        self.content = label()
    }
    var body: some View {
        Button {
            if PurchaseManager.shared.isPremiumUser {
                action()
            } else {
                isAlertPresented.toggle()
            }
        } label: {
            content
        }
        .alert(reason, isPresented: $isAlertPresented) {
            Button("Cancel", role: .cancel) {
                
            }
            Button("Subscribe") {
                PurchaseManager.shared.subscriptionViewPresent.toggle()
            }
        }
    }
}

struct PremiumNavigationLink<Content: View>: View {
    let destination: Content
    let content: Content
    let reason: String
    
    @State private var isAlertPresented: Bool = false
    init(reason: String, @ViewBuilder destination: () -> Content, @ViewBuilder label: () -> Content) {
        self.reason = reason
        self.destination = destination()
        self.content = label()
    }
    var body: some View {
        if PurchaseManager.shared.isPremiumUser {
            NavigationLink {
                destination
            } label: {
                content
            }
        } else {
            Button {
                self.isAlertPresented.toggle()
            } label: {
                content
            }
            .alert(reason, isPresented: $isAlertPresented) {
                Button("Cancel", role: .cancel) {
                    
                }
                Button("Subscribe") {
                    PurchaseManager.shared.subscriptionViewPresent.toggle()
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
