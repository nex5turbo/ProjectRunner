//
//  DiaryAddSheet.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/24/24.
//

import SwiftUI

struct DiaryAddSheet: View {
    @Environment(\.dismiss) private var dismiss
    private let day: Day
    @Binding var appData: AppData
    @State private var height: CGFloat = 1
    @State private var content: String = ""

    init(day: Day, appData: Binding<AppData>) {
        self.day = day
        self._appData = appData
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text(day.toDate!.toString())
                .font(.title2.weight(.semibold))
            HStack {
                TextField("test", text: $content, prompt: Text("How was your day?"))// TODO: locallize
                    .padding(.vertical, 8)
                    .padding(.horizontal)
                    .font(.title3)
                    .foregroundStyle(.black)
                    .tint(.blue)
                Button {
                    guard let date = day.toDate else {
                        return
                    }
                    let newDiary = TDiary(createdAt: date, createdDay: day, content: content)
                    do {
                        try appData.addDiary(diary: newDiary)
                        dismiss()
                    } catch {
                        print(error.localizedDescription)
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.blue.opacity(0.4))
                        .clipShape(Circle())
                        .clipped()
                }
                .padding(8)
            }
            
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.gray.opacity(0.15))
            )
        }
        .padding()
        .overlay {
            GeometryReader { proxy in
                Color.clear
                    .task {
                        self.height = proxy.size.height
                    }
                    .onChange(of: proxy.size) {
                        self.height = proxy.size.height
                    }
            }
        }
        .presentationDetents([.height(height)])
    }
}

#Preview {
    DiaryAddSheet(day: Day(year: 1, month: 1, value: 1), appData: .constant(.init()))
}
