//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import SwiftUI
import Contacts
import PhotosUI

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
    @State private var isPickerPresented: Bool = false
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var imageURL: URL? = nil
    private var isEditing: Bool
    private var title: String {
        isEditing ? "New Contact" : "Edit Contact"
    }
    private let imageSize: CGFloat = 180
    var body: some View {
        VStack {
            CircleName(markColor: newClient.markColor, text: newClient.fullName)
                .setCircleSize(imageSize)

            List {
                Section {
                    TextField("familyName", text: $newClient.familyName, prompt: Text("Family Name"))
                        .keyboardType(.namePhonePad)
                    
                    TextField("givenName", text: $newClient.givenName, prompt: Text("Given Name"))
                        .keyboardType(.namePhonePad)
                }
                .listStyle(.plain)
                
                Section {
                    TextField("email", text: $newClient.email, prompt: Text("E-mail"))
                        .keyboardType(.emailAddress)
                    
                    TextField("phoneNumber", text: $newClient.phoneNumber, prompt: Text("Phone Number"))
                        .keyboardType(.phonePad)
                    TextField("instagram", text: $newClient.instagramId, prompt: Text("Instagram Id"))
                        .keyboardType(.twitter)
                }
                .listStyle(.plain)
                
                Section {
                    ColorSheetButton { color in
                        newClient.markColor = color
                    } label: {
                        HStack {
                            if newClient.markColor != .noColor {
                                Image(systemName: "circle.fill")
                                    .foregroundStyle(newClient.markColor.color)
                            }
                            Text(newClient.markColor == .noColor ? "Select Mark color" : newClient.markColor.title)
                        }
                    }
                    
                    HStack {
                        LabelSheetButton(appData: $appData) { label in
                            newClient.label = label
                        } label: {
                            Text(newClient.label == nil ? "Select Label" : newClient.label!.content)
                        }
                        Spacer()
                        if newClient.label != nil {
                            Button {
                                newClient.label = nil
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.red)
                            }
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.secondarySystemBackground))
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
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
