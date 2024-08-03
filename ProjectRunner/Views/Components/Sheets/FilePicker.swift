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
    let onSelected: ([TFile]) -> Void
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.item])
        picker.allowsMultipleSelection = true
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
                
                if let cloudUrl = FileManager.default.fileCloudFolder(fileName: url.lastPathComponent) {
                    try? data.write(to: cloudUrl)
                }
                try? data.write(to: FileManager.default.fileFolder(fileName: url.lastPathComponent))
                
                let item = TFile(fileName: url.lastPathComponent, fileType: "files")
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
