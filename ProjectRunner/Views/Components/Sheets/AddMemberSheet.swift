//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/8/24.
//

import SwiftUI

struct AddMemberSheet: View {
    @State private var members: [TClient]
    @Binding private var appData: AppData
    let onDismiss: ([TClient]) -> Void
    
    init(members: [TClient], appData: Binding<AppData>, onDismiss: @escaping ([TClient]) -> Void) {
        self._members = State(initialValue: members)
        self._appData = appData
        self.onDismiss = onDismiss
    }
    var body: some View {
        NavigationStack {
            List {
                Section {
                    ForEach(appData.clients, id: \.self) { client in
                        let isSelected = members.contains(client)
                        Button {
                            if isSelected {
                                members.removeAll(where: {$0.id == client.id})
                            } else {
                                members.append(client)
                            }
                        } label: {
                            HStack {
                                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(isSelected ? .blue : .black)
                                Text(client.fullName)
                            }
                        }
                        .foregroundStyle(.black)
                    }
                } header: {
                    HStack  {
                        Text("Contacts")
                            .foregroundStyle(.black)
                        Text("\(appData.clients.count)")
                    }
                    .font(.title3)
                }
            }
            .navigationTitle("Members")
        }
        .onDisappear {
            onDismiss(members)
        }
    }
}

#Preview {
    ContentView()
}
