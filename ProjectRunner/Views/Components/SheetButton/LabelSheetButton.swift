//
//  LabelSheetButton.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/9/24.
//

import SwiftUI

enum LabelSheetType {
    case mutiple
    case single
}

struct LabelSheetButton<Content: View>: View {
    @State private var schedule: Schedulable
    @Binding private var appData: AppData
    let type: LabelSheetType
    let onSelect: ([TLabel]) -> Void
    let onSelectOne: (TLabel) -> Void
    let content: Content
    
    @State private var isSheetPresented: Bool = false
    init(appData: Binding<AppData>, schedule: Schedulable, onSelect: @escaping ([TLabel]) -> Void, @ViewBuilder label: () -> Content) {
        self.type = .mutiple
        self._appData = appData
        self.onSelect = onSelect
        self.content = label()
        self.onSelectOne = { _ in }
        self.schedule = schedule
    }
    
    init(appData: Binding<AppData>, onSelect: @escaping (TLabel) -> Void, @ViewBuilder label: () -> Content) {
        self.type = .single
        self._appData = appData
        self.onSelect = { _ in }
        self.content = label()
        self.onSelectOne = onSelect
        self.schedule = TTask.emptyTask()
    }
    var body: some View {
        Button {
            self.isSheetPresented.toggle()
        } label: {
            content
        }
        .sheet(isPresented: $isSheetPresented) {
            switch type {
            case .mutiple:
                LabelSheet(schedule: schedule, appData: $appData) { labels in
                    onSelect(labels)
                }
                .presentationDetents([.medium, .large])
            case .single:
                LabelSheetSingle(appData: $appData) { label in
                    onSelectOne(label)
                }
                .presentationDetents([.medium, .large])
            }
            
        }
    }
}

#Preview {
    ContentView()
}
