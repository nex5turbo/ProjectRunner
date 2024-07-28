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
    let condition: Bool
    
    @State private var isAlertPresented: Bool = false
    
    init(reachedLimit condition: Bool, reason: String, action: @escaping () -> Void, @ViewBuilder label: () -> Content) {
        self.reason = reason
        self.action = action
        self.content = label()
        self.condition = condition
    }
    var body: some View {
        Button {
            if PurchaseManager.shared.isPremiumUser || !condition {
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

struct PremiumNavigationLink<Content: View, Destination: View>: View {
    let destination: Destination
    let content: Content
    let reason: String
    /// reachedLimit true -> isPremiumUser가 아님, false => 프리미엄 유저임
    let condition: Bool
    
    @State private var isAlertPresented: Bool = false
    init(reachedLimit condition: Bool, reason: String, @ViewBuilder destination: () -> Destination, @ViewBuilder label: () -> Content) {
        self.reason = reason
        self.destination = destination()
        self.content = label()
        self.condition = condition
    }
    var body: some View {
        if PurchaseManager.shared.isPremiumUser || !condition {
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
