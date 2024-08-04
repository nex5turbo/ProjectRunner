//
//  ImageViewer.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 8/4/24.
//

import SwiftUI

struct ImageViewer: View {
    @Environment(\.dismiss) private var dismiss
    let files: [TFile]
    @Binding private var currentIndex: Int
    @State private var isHeaderPresented: Bool = true
    
    init(files: [TFile], currentIndex: Binding<Int>) {
        self.files = files
        self._currentIndex = currentIndex
    }
    var body: some View {
        ZStack {
            TabView(selection: $currentIndex) {
                ForEach(Array(files.enumerated()), id: \.element.id) { (index, file) in
                    Group {
                        if file.fileType == "images" {
                            if let url = file.validUrl {
                                AsyncImage(url: url) { image in
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .edgesIgnoringSafeArea(.all)
                                } placeholder: {
                                    ProgressView()
                                }
                            } else {
                                Text("Invalid file url")
                            }
                        } else if file.fileType == "files" {
                            
                        } else if file.fileType == "videos" {
                            if let url = file.validUrl {
                                VideoViewer(url: url)
                            } else {
                                Text("Invalid file url")
                            }
                        }
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onTapGesture {
                self.isHeaderPresented.toggle()
            }
            
            VStack(spacing: 0) {
                ZStack {
                    HStack {
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.white)
                                .bold()
                                .padding(8)
                                .background(.black)
                                .clipShape(Circle())
                                .clipped()
                        }

                        Spacer()
                    }
                    HStack {
                        Spacer()
                        Text("\(currentIndex + 1) / \(files.count)")
                            .bold()
                        Spacer()
                    }
                }
                .padding()
                .background(.white)
                
                Divider()
                
                Spacer()
            }
            .opacity(isHeaderPresented ? 1 : 0)
            .animation(.spring, value: isHeaderPresented)
        }
    }
}

#Preview {
    ImageViewer(files: [], currentIndex: .constant(0))
}
