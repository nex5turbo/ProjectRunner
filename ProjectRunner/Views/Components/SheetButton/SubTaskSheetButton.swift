//
//  SubTaskSheetButton.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/9/24.
//

import SwiftUI

struct SubTaskSheetButton<Content: View>: View {
    private let schedule: Schedulable
    @Binding private var appData: AppData
    let onSelect: ([String]) -> Void
    let content: Content
    
    @State private var isSheetPresented: Bool = false
    init(appData: Binding<AppData>, schedule: Schedulable, onSelect: @escaping ([String]) -> Void, @ViewBuilder label: () -> Content) {
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
            SubTasksSheet(schedule: schedule, appData: $appData) { taskIds in
                onSelect(taskIds)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    ContentView()
}
