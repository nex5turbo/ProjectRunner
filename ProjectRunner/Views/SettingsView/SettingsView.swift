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
                    let encoder = JSONEncoder()
                    guard let data = try? encoder.encode(appData) else {
                        return
                    }
                    guard let string = String(data: data, encoding: .utf8) else {
                        return
                    }
                    print(string)
                }

                Button("Load Data") {
                    
                }
            }
            #endif
            
            Button("Set Tutorial") {
                do {
                    try appData.loadTutorial()
                } catch {
                    print(error.localizedDescription)
                }
            }
            
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
