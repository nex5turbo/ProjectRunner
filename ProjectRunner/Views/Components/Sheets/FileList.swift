//
//  FileList.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 8/3/24.
//

import SwiftUI

struct FileList: View {
    private var isBigSize: Bool = true
    private let fileAttachable: FileAttachable
    private let onDelete: (TFile) -> Void
    
    private var height: CGFloat {
        if fileAttachable.files.isEmpty {
            return 70
        } else {
            return isBigSize ? 140 : 70
        }
    }
    private let cornerRadius: CGFloat = 16
    
    init(fileAttachable: FileAttachable, onDelete: @escaping (TFile) -> Void) {
        self.fileAttachable = fileAttachable
        self.onDelete = onDelete
    }
    
    var body: some View {
        if fileAttachable.files.isEmpty {
            HStack {
                Spacer()
                Text("No attached file")
                    .font(.headline)
                    .foregroundStyle(.gray)
                Spacer()
            }
            .frame(height: height)
        } else {
            ScrollView(.horizontal) {
                HStack {
                    ForEach(fileAttachable.files, id: \.self) { file in
                        if let image = file.cloudUrl?.asSmallImage {
                            fileImage(image, file: file)
                        } else if let image = file.folderUrl.asSmallImage {
                            fileImage(image, file: file)
                        } else {
                            let fileName = file.fileName
                            VStack(alignment: .leading, spacing: 0) {
                                Text(fileName)
                                    .font(.subheadline.weight(.semibold))
                                Text(file.fileExtension.uppercased())
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                            }
                            .padding(.horizontal)
                            .frame(height: height)
                            .cornerRadius(cornerRadius)
                            .overlay {
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(.gray.opacity(0.3), lineWidth: 1.2)
                            }
                            .overlay {
                                closeButton {
                                    onDelete(file)
                                }
                            }
                            .padding(4)
                        }
                        
                    }
                }
                .padding(.horizontal)
            }
            .scrollIndicators(.never)
            .animation(.spring, value: fileAttachable.files)
        }
    }
    
    @ViewBuilder func fileImage(_ image: UIImage, file: TFile) -> some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFill()
            .frame(width: height, height: height)
            .cornerRadius(cornerRadius)
            .overlay {
                closeButton {
                    onDelete(file)
                }
            }
            .padding(4)
    }
    
    @ViewBuilder func closeButton(_ action: @escaping () -> Void) -> some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    action()
                } label: {
                    Circle().fill(.black)
                        .stroke(.white, lineWidth: 2)
                        .overlay {
                            Image(systemName: "xmark")
                                .resizable()
                                .bold()
                                .frame(width: 8, height: 8)
                                .foregroundStyle(.white)
                        }
                        .frame(width: 16, height: 16)
                }
                .offset(x: 4, y: -4)
            }
            Spacer()
        }
    }
    
    public func bigSize(_ value: Bool) -> Self {
        var view = self
        view.isBigSize = value
        return view
    }
}

#Preview {
    ContentView()
}
