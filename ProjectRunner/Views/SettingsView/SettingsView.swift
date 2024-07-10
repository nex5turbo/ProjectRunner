//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/28/24.
//

import SwiftUI

struct SettingsView: View {
    @Binding var appData: AppData
    var body: some View {
        List {
            #if DEBUG
            Section("Data") {
                Button("Export Data") {
                    
                }

                Button("Load Data") {
                    
                }
            }
            #endif
            
            Section("Creators") {
                Text("Designed by Anfaloumrani")
                Text("Created by Wonyoung Jang")
            }
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    ContentView()
}
