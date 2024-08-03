//
//  FileList.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 8/3/24.
//

import SwiftUI

struct FileList: View {
    private let fileAttachable: FileAttachable
    private let onDelete: (TFile) -> Void
    
    private let height: CGFloat = 70
    private let cornerRadius: CGFloat = 16
    
    init(fileAttachable: FileAttachable, onDelete: @escaping (TFile) -> Void) {
        self.fileAttachable = fileAttachable
        self.onDelete = onDelete
    }
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(fileAttachable.files, id: \.self) { file in
                    if let image = file.cloudUrl?.asSmallImage {
                        fileImage(image, file: file)
                    } else if let image = file.folderUrl.asSmallImage {
                        fileImage(image, file: file)
                    } else {
                        let fileName = file.fileName
                        Text(fileName)
                            .frame(height: height)
                            .padding(.horizontal)
                            .cornerRadius(cornerRadius)
                            .overlay {
                                VStack {
                                    HStack {
                                        Spacer()
                                        Button {
                                            onDelete(file)
                                        } label: {
                                            Image(systemName: "xmark")
                                                .font(.footnote)
                                                .bold()
                                                .padding(8)
                                        }
                                    }
                                    Spacer()
                                }
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(.gray.opacity(0.3), lineWidth: 1.2)
                            }
                            .padding(4)
                    }
                    
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder func fileImage(_ image: UIImage, file: TFile) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: height, height: height)
            .cornerRadius(cornerRadius)
            .overlay {
                VStack {
                    HStack {
                        Spacer()
                        Button {
                            onDelete(file)
                        } label: {
                            Image(systemName: "xmark")
                                .font(.footnote)
                                .bold()
                                .padding(8)
                        }
                    }
                    Spacer()
                }
            }
            .padding(4)
    }
}

#Preview {
    ContentView()
}
