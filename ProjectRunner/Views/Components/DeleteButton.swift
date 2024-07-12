//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/2/24.
//

import SwiftUI

struct DeleteButton: View {
    @Environment(\.dismiss) private var dismiss
    @State private var isDeleteConfirm: Bool = false
    let action: () -> Void
    let secondAction: (() -> Void)?
    
    init( action: @escaping () -> Void, secondAction: (() -> Void)? = nil) {
        self.action = action
        self.secondAction = secondAction
    }
    var body: some View {
        Button {
            self.isDeleteConfirm = true
        } label: {
            HStack {
                Image(systemName: "trash.fill")
                Text("Delete")
            }
            .foregroundStyle(.white)
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(.red)
            .cornerRadius(10)
        }
        .confirmationDialog("Are you sure to delete?", isPresented: $isDeleteConfirm) {
            if let secondAction {
                Button("Delete Sub Tasks too", role: .destructive) {
                    secondAction()
                    dismiss()
                }
            }
            Button("Delete", role: .destructive) {
                action()
                dismiss()
            }
            
            Button("Cancel", role: .cancel) {
                
            }
        }
    }
}

#Preview {
    DeleteButton {
        
    }
}
