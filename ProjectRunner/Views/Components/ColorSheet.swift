//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/8/24.
//

import SwiftUI

struct ColorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var appData: AppData
    let onSelect: (MarkColor) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(MarkColor.allCases, id: \.self) { color in
                    Button {
                        onSelect(color)
                        dismiss()
                    } label: {
                        HStack {
                            Image(systemName: "circle.fill")
                                .foregroundStyle(color.color)
                            Text(color.title)
                                .foregroundStyle(.black)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Mark color")
        }
    }
}

#Preview {
    ContentView()
}
