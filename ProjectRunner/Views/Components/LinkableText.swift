//
//  LInkableText.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/29/24.
//

import SwiftUI

struct LinkableText: View {
    let content: String
    init(_ content: String) {
        self.content = content
    }
    var body: some View {
        Text(content.linkify())
            .textSelection(.enabled)
    }
}

#Preview {
    LinkableText("")
}
