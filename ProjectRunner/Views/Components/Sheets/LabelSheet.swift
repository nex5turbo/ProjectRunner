//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/7/24.
//

import SwiftUI

struct LabelSheet: View {
    @State private var schedule: Schedulable
    @Binding private var appData: AppData
    let onDismiss: ([TLabel]) -> Void
    @State private var content: String = ""
    init(schedule: Schedulable, appData: Binding<AppData>, onDismiss: @escaping ([TLabel]) -> Void) {
        self._schedule = State(initialValue: schedule)
        self._appData = appData
        self.onDismiss = onDismiss
    }
    var body: some View {
        VStack(spacing: 0) {
            TextField("content", text: $content, prompt: Text("Label"))
                .font(.title)
                .padding()
                .padding(.top)
                .onSubmit {
                    do {
                        appData.labels.append(TLabel(content))
                        try appData.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            Divider()
            List {
                ForEach(appData.labels, id: \.self) { label in
                    HStack {
                        let isSelected = schedule.labels.contains(label)
                        Button {
                            if isSelected {
                                schedule.labels.removeAll(where: {$0.id == label.id})
                            } else {
                                schedule.labels.append(label)
                            }
                        } label: {
                            HStack {
                                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                                    .foregroundStyle(isSelected ? .blue : .black)
                                Text(label.content)
                            }
                        }
                        .foregroundStyle(.black)
                        Spacer()
                        // 일단 없애기
//                            Button(role: .destructive) {
//                                appData.labels.removeAll(where: { $0 == label })
//                                do {
//                                    try appData.save()
//                                } catch {
//                                    print(error.localizedDescription)
//                                }
//                            } label: {
//                                Image(systemName: "trash.fill")
//                            }
                    }
                }
            }
        }
        .onDisappear {
            onDismiss(schedule.labels)
        }
    }
}

struct LabelSheetSingle: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (TLabel) -> Void
    @Binding var appData: AppData
    init(appData: Binding<AppData>, onSelect: @escaping (TLabel) -> Void) {
        self.onSelect = onSelect
        self._appData = appData
    }
    @State private var content: String = ""
    var body: some View {
        VStack(spacing: 0) {
            TextField("content", text: $content, prompt: Text("Label"))
                .font(.title)
                .padding()
                .padding(.top)
                .onSubmit {
                    do {
                        appData.clientLabels.append(TLabel(content))
                        try appData.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            Divider()
            List {
                ForEach(appData.clientLabels, id: \.self) { label in
                    HStack {
                        Button {
                            onSelect(label)
                            dismiss()
                        } label: {
                            Text(label.content)
                        }
                        .foregroundStyle(.black)
                        Spacer()
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
