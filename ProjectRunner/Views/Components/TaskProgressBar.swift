//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/4/24.
//

import SwiftUI

struct TaskProgressBar: View {
    let tasks: [TTask]
    init(tasks: [TTask]) {
        self.tasks = tasks
    }
    
    private var hideText: Bool = false
    @State private var textHeight: CGFloat = 16
    @State private var textWidth: CGFloat = 24
    var body: some View {
        HStack {
            if !hideText {
                Text("Sub tasks")
                    .font(.headline)
                    .bold()
            }
            let taskCount = tasks.count
            let doneCount = tasks.filter { $0.status == .done }.count
            
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(.gray)
                    .overlay {
                        HStack {
                            RoundedRectangle(cornerRadius: 0)
                                .fill(.blue)
                                .frame(width: textWidth * (CGFloat(doneCount) / CGFloat(max(1, taskCount))), height: textHeight)
                            Spacer(minLength: 0)
                        }
                    }
                    .cornerRadius(8)
                    .clipped()
                    .frame(width: textWidth, height: textHeight)
                Text("\(doneCount) / \(taskCount)")
                    .font(.system(size: 7, weight: .semibold))
                    .foregroundStyle(.white)
                    .overlay {
                        GeometryReader { proxy in
                            Color.clear.task {
                                self.textHeight = proxy.size.height + 6
                                self.textWidth = proxy.size.width + 12
                            }
                        }
                    }
            }
            
            
            
        }
    }
    
    public func hideHeader() -> Self {
        var view = self
        view.hideText = true
        
        return view
    }
}

#Preview {
    ContentView()
}
