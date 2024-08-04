//
//  FilePicker.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 8/2/24.
//

import SwiftUI
import MobileCoreServices
import UniformTypeIdentifiers

struct FilePicker: UIViewControllerRepresentable {
    let multiSelectEnabled: Bool
    let onSelected: ([TFile]) -> Void
    
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
        picker.allowsMultipleSelection = multiSelectEnabled
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {
        // No update needed
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let parent: FilePicker

        init(_ parent: FilePicker) {
            self.parent = parent
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            let files: [TFile] = urls.compactMap { url in
                if !url.startAccessingSecurityScopedResource() {
                    return nil
                }
                var data: Data
                do {
                    data = try Data(contentsOf: url)
                } catch {
                    print(error.localizedDescription)
                    return nil
                }
                
                let item = TFile(fileName: url.lastPathComponent)
                
                if let cloudUrl = item.cloudUrl {
                    try? data.write(to: cloudUrl)
                }
                try? data.write(to: item.folderUrl)
                
                
                return item
            }
            parent.onSelected(files)
            parent.presentationMode.wrappedValue.dismiss()
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
