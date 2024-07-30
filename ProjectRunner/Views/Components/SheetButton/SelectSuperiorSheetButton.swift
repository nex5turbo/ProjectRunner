//
//  SelectSuperiorSheetButton.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/9/24.
//

import SwiftUI

struct SelectSuperiorSheetButton<Content: View>: View {
    @State private var task: TTask
    @Binding private var appData: AppData
    let onSelect: (Schedulable) -> Void
    let content: Content
    
    @State private var isSheetPresented: Bool = false
    init(appData: Binding<AppData>, task: TTask, onSelect: @escaping (Schedulable) -> Void, @ViewBuilder label: () -> Content) {
        self._appData = appData
        self.onSelect = onSelect
        self.content = label()
        self.task = task
    }
    var body: some View {
        Button {
            self.isSheetPresented.toggle()
        } label: {
            content
        }
        .sheet(isPresented: $isSheetPresented) {
            SelectSuperiorSheet(task: task, appData: $appData) { superior in
                self.task.superiorId = superior.id
                onSelect(superior)
            }
            .presentationDetents([.medium, .large])
        }
    }
}

#Preview {
    ContentView()
}
