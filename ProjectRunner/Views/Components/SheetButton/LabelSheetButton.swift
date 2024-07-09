//
//  LabelSheetButton.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/9/24.
//

import SwiftUI

struct LabelSheetButton<Content: View>: View {
    @State private var schedule: Schedulable
    @Binding private var appData: AppData
    let onSelect: ([TLabel]) -> Void
    let content: Content
    
    @State private var isSheetPresented: Bool = false
    init(appData: Binding<AppData>, schedule: Schedulable, onSelect: @escaping ([TLabel]) -> Void, @ViewBuilder label: () -> Content) {
        self._appData = appData
        self.onSelect = onSelect
        self.content = label()
        self.schedule = schedule
    }
    var body: some View {
        Button {
            self.isSheetPresented.toggle()
        } label: {
            content
        }
        .sheet(isPresented: $isSheetPresented) {
            LabelSheet(schedule: schedule, appData: $appData) { labels in
                onSelect(labels)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    ContentView()
}
