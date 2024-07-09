//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import SwiftUI

struct ClientView: View {
    @Binding var appData: AppData
    
    var body: some View {
        List($appData.clients, id: \.self) { $client in
            NavigationLink {
                ClientDetailView(client: client, appData: $appData)
            } label: {
                ClientItemView(appData: $appData, client: client)
            }
        }
        .navigationTitle("Contact")
        .toolbar {
            ToolbarItem {
                NavigationLink {
                    ClientAddView(appData: $appData)
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .overlay {
            if appData.clients.isEmpty {
                VStack {
                    Text("No saved contact")
                        .font(.headline)
                        .bold()
                }
            }
        }
    }
    
    func fetchFiles() throws {
        let folder = try FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false)
        
        try FileManager.default.contentsOfDirectory(at: folder, includingPropertiesForKeys: nil)
    }
    
}

#Preview {
    ContentView()
}
