//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import SwiftUI


struct ClientDetailView: View {
    @State var client: TClient
    @Binding var appData: AppData
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                VStack {
                    Text("E-mail")
                        .font(.headline)
                    Text(client.email == "" ? "No email Address" : client.email)
                }
                .padding()
                
                VStack {
                    Text("Phone Number")
                        .font(.headline)
                    Text(client.phoneNumber == "" ? "No Phone Number" : client.phoneNumber)
                }
                .padding()
                
                HStack {
                    // message or call
                    Button {
                        client.openMessage()
                    } label: {
                        HStack {
                            Text("Contact")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.green)
                        .cornerRadius(10)
                    }
                    .disabled(client.phoneNumber == "")
                    
                    // email
                    Button {
                        client.openEmail()
                    } label: {
                        HStack {
                            Text("Mail")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.teal)
                        .cornerRadius(10)
                    }
                    .disabled(client.email == "")
                    
                    // open instagram
                    Button {
                        client.openInstagram()
                    } label: {
                        HStack {
                            Text("Instagram")
                                .font(.headline)
                        }
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(.purple)
                        .cornerRadius(10)
                    }
                    .disabled(client.instagramId == "")
                }
                .padding(.horizontal)
                
                BlockDivider()
                
                DeleteButton {
                    do {
                        try appData.deleteClient(client: client)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
                .padding()
            }
        }
        .navigationTitle(client.fullName)
        .toolbar {
            ToolbarItem {
                NavigationLink("Edit") {
                    ClientAddView(client: client, appData: $appData)
                }
            }
        }
        .onChange(of: appData) { newValue in
            guard let newClient = appData.clients.first(where: { $0.id == self.client.id }) else {
                return
            }
            self.client = newClient
        }
    }
}

#Preview {
    ContentView()
}
