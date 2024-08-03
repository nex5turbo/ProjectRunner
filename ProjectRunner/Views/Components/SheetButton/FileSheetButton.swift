//
//  FileSheetButton.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 8/3/24.
//

import SwiftUI

struct FileSheetButton: View {
    private let onSelected: ([TFile]) -> Void
    
    init(onSelected: @escaping ([TFile]) -> Void) {
        self.onSelected = onSelected
    }
    
    @State private var isFilePickerPresented: Bool = false
    @State private var isImagePickerPresented: Bool = false
    @State private var isFileConfirmPresented: Bool = false
    
    var body: some View {
        PremiumButton(reachedLimit: true, reason: "Subscribe and attach files to your schedules!", action: {
            self.isFileConfirmPresented.toggle()
        }, label: {
            HStack {
                Text("+")
                    .padding(8)
                    .foregroundStyle(.gray)
                    .background(.gray.opacity(0.2))
                    .clipShape(Circle())
                    .clipped()
            }
            .font(.headline)
        })
        .confirmationDialog("", isPresented: $isFileConfirmPresented) {
            Button("Files") {
                self.isFilePickerPresented.toggle()
            }
            
            Button("Images") {
                self.isImagePickerPresented.toggle()
            }
        }
        .sheet(isPresented: $isFilePickerPresented) {
            FilePicker { files in
                onSelected(files)
            }
        }
        .sheet(isPresented: $isImagePickerPresented) {
            ImagePicker { files in
                onSelected(files)
            }
        }
    }
}

#Preview {
    FileSheetButton { _ in
        
    }
}
