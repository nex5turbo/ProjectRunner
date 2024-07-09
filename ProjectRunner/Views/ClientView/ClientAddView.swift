//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import SwiftUI

struct ClientAddView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var appData: AppData
    init(appData: Binding<AppData>) {
        self._newClient = State(initialValue: TClient.empty())
        self._appData = appData
        self.isEditing = false
    }
    
    init(client: TClient, appData: Binding<AppData>) {
        self._newClient = State(initialValue: client)
        self._appData = appData
        self.isEditing = true
        
    }
    @State private var newClient: TClient
    private var isEditing: Bool
    private var title: String {
        isEditing ? "New Contact" : "Edit Contact"
    }
    private let imageSize: CGFloat = 120
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                Menu {
                    ForEach(ClientType.allCases, id: \.self) { type in
                        Button(type.rawValue) {
                            self.newClient.type = type
                        }
                    }
                } label: {
                    Text("This person is my \(newClient.type.rawValue)")
                }
                
                TextField("familyName", text: $newClient.familyName, prompt: Text("Family Name"))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.namePhonePad)
                
                TextField("givenName", text: $newClient.givenName, prompt: Text("Given Name"))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.namePhonePad)
                
                TextField("email", text: $newClient.email, prompt: Text("E-mail"))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                
                TextField("phoneNumber", text: $newClient.phoneNumber, prompt: Text("Phone Number"))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.phonePad)
                
                TextField("instagram", text: $newClient.instagramId, prompt: Text("Instagram Id"))
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.twitter)
                
                Spacer()
            }
            .navigationTitle(title)
            .font(.headline)
            .padding()
            .toolbar {
                ToolbarItemGroup {
                    Button("save") {
                        do {
                            try appData.addClient(client: newClient)
                            dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
