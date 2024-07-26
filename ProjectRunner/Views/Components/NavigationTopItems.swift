//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/4/24.
//

import SwiftUI

struct NavigationTopItems<Contents: View>: View {
    @ViewBuilder let contents: Contents
    init(@ViewBuilder contents: () -> Contents) {
        self.contents = contents()
    }
    
    private var isDividerPresented: Bool = true
    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal) {
                HStack(spacing: 8) {
                    contents
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .scrollIndicators(.never)
            if isDividerPresented {
                Divider()
            }
        }
        .background(.white)
    }
    
    public func hideDivider() -> Self {
        var view = self
        view.isDividerPresented = false
        
        return view
    }
}

#Preview {
    ContentView()
}
