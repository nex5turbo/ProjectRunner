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
    @State private var isShareSheetPresented: Bool = false
    
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
                                VStack {
                                    Spacer()
                                    Text("Invalid file url")
                                        .font(.headline)
                                    Spacer()
                                }
                            }
                        } else if file.fileType == "files" {
                            VStack {
                                Spacer()
                                Text(file.fileName)
                                    .font(.headline)
                                Spacer()
                            }
                        } else if file.fileType == "videos" {
                            if let url = file.validUrl {
                                VideoViewer(url: url)
                            } else {
                                VStack {
                                    Spacer()
                                    Text("Invalid file url")
                                        .font(.headline)
                                    Spacer()
                                }
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
                                .font(.caption)
                                .foregroundStyle(.white)
                                .bold()
                                .padding(8)
                                .background(.black)
                                .clipShape(Circle())
                                .clipped()
                        }

                        Spacer()
                        
                        Button {
                            self.isShareSheetPresented.toggle()
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                                .font(.caption)
                                .foregroundStyle(.white)
                                .bold()
                                .padding(8)
                                .background(.black)
                                .clipShape(Circle())
                                .clipped()
                        }
                        .sheet(isPresented: $isShareSheetPresented) {
                            if let url = files[currentIndex].validUrl {
                                ActivityViewController(activityItems: [url])
                            } else {
                                Text("Invalid file url")
                            }
                        }
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

struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    let excludedActivityTypes: [UIActivity.ActivityType]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        controller.excludedActivityTypes = excludedActivityTypes
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}
