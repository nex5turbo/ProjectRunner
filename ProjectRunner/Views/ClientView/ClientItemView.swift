//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/1/24.
//

import SwiftUI

struct ClientItemView: View {
    @Binding var appData: AppData
    @State var client: TClient
    init(appData: Binding<AppData>, client: TClient) {
        self._appData = appData
        self._client = State(initialValue: client)
    }
    
    private let imageSize: CGFloat = 40
    private var hideContact: Bool = false
    var body: some View {
        HStack {
            if let imageUrl = client.imageURL {
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                } placeholder: {
                    
                }
                .aspectRatio(contentMode: ContentMode.fill)
                .frame(width: imageSize, height: imageSize)
                .clipShape(Circle())
                .clipped()
            } else {
                CircleName(markColor: client.markColor, text: client.fullName)
                    .setCircleSize(imageSize)
            }
            VStack(alignment: .leading) {
                Text(client.fullName)
                    .font(.title2)
                if let label = client.label {
                    Text(label.content)
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
            }
            Spacer()
            if !hideContact {
                Menu {
                    Section {
                        Text(client.fullName + " \(client.getFlag())\n" + client.phoneNumber)
                    }
                    Button {
                        client.openMessage()
                    } label: {
                        Image(systemName: "message.fill")
                        Text("Message")
                    }
                    .disabled(client.phoneNumber == "")
                    
                    Button {
                        client.openCall()
                    } label: {
                        Image(systemName: "phone.fill")
                        Text("Call")
                    }
                    .disabled(client.phoneNumber == "")
                    
                    Button {
                        client.openEmail()
                    } label: {
                        Text("Mail")
                        Image(systemName: "envelope.fill")
                    }
                    .disabled(client.email == "")
                    
                    Button {
                        client.openInstagram()
                    } label: {
                        Text("Instagram")
                        Image(systemName: "heart.fill")
                    }
                    .disabled(client.instagramId == "")
                    
                } label: {
                    Text("Contact")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.black)
                }
            }
        }
    }
    
    func hideButton() -> Self {
        var view = self
        view.hideContact = true
        
        return view
    }
}

#Preview {
    ContentView()
}
