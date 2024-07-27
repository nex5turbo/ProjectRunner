//
//  AddMemberSheetButton.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/9/24.
//

import SwiftUI

struct AddMemberSheetButton<Content: View>: View {
    let onSelect: ([TClient]) -> Void
    let content: Content
    @Binding var appData: AppData
    let members: [TClient]
    @State private var isSheetPresented: Bool = false
    init(appData: Binding<AppData>, members: [TClient], onSelect: @escaping ([TClient]) -> Void, @ViewBuilder label: () -> Content) {
        self._appData = appData
        self.onSelect = onSelect
        self.content = label()
        self.members = members
    }
    var body: some View {
        Button {
            self.isSheetPresented.toggle()
        } label: {
            content
        }
        .sheet(isPresented: $isSheetPresented) {
            AddMemberSheet(members: members, appData: $appData) { members in
                onSelect(members)
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    ContentView()
}
