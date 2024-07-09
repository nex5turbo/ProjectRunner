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
    
    let buttonBackground: Color = .secondary
    let buttonFont: Font = .footnote
    let imageHeight: CGFloat = 16
    let disableColor: Color = .white.opacity(0.3)
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading) {
                    Text("E-mail")
                        .font(.headline)
                    Text(client.email == "" ? "No email Address" : client.email)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Phone Number")
                        .font(.headline)
                    Text(client.phoneNumber == "" ? "No Phone Number" : client.phoneNumber)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading) {
                    Text("Instagram")
                        .font(.headline)
                    Text(client.instagramId == "" ? "No Instagram ID" : client.instagramId)
                }
                .padding(.horizontal)
                
                HStack {
                    // message or call
                    Button {
                        client.openMessage()
                    } label: {
                        contactButton(message: "Message", imageName: "message.fill")
                    }
                    .foregroundStyle(client.phoneNumber == "" ? disableColor : .white)
                    .disabled(client.phoneNumber == "")
                    
                    Button {
                        client.openCall()
                    } label: {
                        contactButton(message: "Call", imageName: "phone.fill")
                    }
                    .foregroundStyle(client.phoneNumber == "" ? disableColor : .white)
                    .disabled(client.phoneNumber == "")
                    
                    // email
                    Button {
                        client.openEmail()
                    } label: {
                        contactButton(message: "Mail", imageName: "envelope.fill")
                    }
                    .foregroundStyle(client.email == "" ? disableColor : .white)
                    .disabled(client.email == "")
                    
                    // open instagram
                    Button {
                        client.openInstagram()
                    } label: {
                        contactButton(message: "Instagram", imageName: "heart.fill")
                    }
                    .foregroundStyle(client.instagramId == "" ? disableColor : .white)
                    .disabled(client.instagramId == "")
                }
                .padding(.horizontal)
                .padding(.bottom)
                
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
        .navigationTitle(client.fullName + " " + client.getFlag())
        .toolbar {
            ToolbarItem {
                NavigationLink("Edit") {
                    ClientAddView(client: client, appData: $appData)
                }
            }
        }
    }
    
    @ViewBuilder func contactButton(message: String, imageName: String) -> some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: imageHeight, height: imageHeight)
            Text(message)
                .font(buttonFont)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(buttonBackground)
        .cornerRadius(10)
    }
}

#Preview {
    ContentView()
}
