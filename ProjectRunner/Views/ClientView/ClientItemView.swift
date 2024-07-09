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
    private let imageSize: CGFloat = 50
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
            }
        }
    }
}

#Preview {
    ContentView()
}
