//
//  View+Extensions.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/29/24.
//

import Foundation
import SwiftUI

struct DragGestureViewModifier: ViewModifier {
    @GestureState private var isDragging: Bool = false
    @State var gestureState: GestureStatus = .idle

    var onStart: (() -> Void)?
    var onUpdate: ((DragGesture.Value) -> Void)?
    var onEnd: ((DragGesture.Value) -> Void)?
    var onCancel: (() -> Void)?

    func body(content: Content) -> some View {
        content
            .highPriorityGesture(
                DragGesture()
                    .updating($isDragging) { _, isDragging, _ in
                        isDragging = true
                    }
                    .onChanged(onDragChange(_:))
                    .onEnded(onDragEnded(_:))
            )
            .onChange(of: gestureState) {
                guard gestureState == .started else { return }
                gestureState = .active
            }
            .onChange(of: isDragging) {
                if isDragging, gestureState != .started {
                    gestureState = .started
                    onStart?()
                } else if !isDragging, gestureState != .ended {
                    gestureState = .cancelled
                    onCancel?()
                }
            }
    }

    func onDragChange(_ value: DragGesture.Value) {
        guard gestureState == .started || gestureState == .active else { return }
        onUpdate?(value)
    }

    func onDragEnded(_ value: DragGesture.Value) {
        gestureState = .ended
        onEnd?(value)
    }

    enum GestureStatus: Equatable {
        case idle
        case started
        case active
        case ended
        case cancelled
    }
}

extension View {
    public func dragGesture(
        onStart: (() -> Void)? = nil,
        onUpdate: ((DragGesture.Value) -> Void)? = nil,
        onEnded: ((DragGesture.Value) -> Void)? = nil,
        onCancel: (() -> Void)? = nil
    ) -> some View {
        let view = DragGestureViewModifier(
            onStart: onStart,
            onUpdate: onUpdate,
            onEnd: onEnded,
            onCancel: onCancel
        )
        
        return self.modifier(view)
    }
}
