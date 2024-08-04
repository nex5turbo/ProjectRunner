//
//  ImagePicker.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 8/1/24.
//

import Foundation
import SwiftUI
import YPImagePicker

struct ImagePicker: UIViewControllerRepresentable {
    let onImageSelected: ([TFile]) -> Void
    let multiSelectEnabled: Bool
    init(multiSelectEnabled: Bool, onImageSelected: @escaping ([TFile]) -> Void) {
        self.multiSelectEnabled = multiSelectEnabled
        self.onImageSelected = onImageSelected
    }
    func makeUIViewController(context: Context) -> some UIViewController {
        var config = YPImagePickerConfiguration()

        config.showsPhotoFilters = false
        config.library.defaultMultipleSelection = multiSelectEnabled
        config.showsVideoTrimmer = true
        config.screens = [.library]
        config.library.maxNumberOfItems = 10
        config.library.minNumberOfItems = 1
        YPImagePickerConfiguration.shared = config
        
        let picker = YPImagePicker(configuration: config)
        picker.delegate = context.coordinator
        
        picker.didFinishPicking { items, cancelled in
            if !cancelled {
                let photos: [TFile] = items.compactMap {
                    do {
                        return try $0.saveToFolder()
                    } catch {
                        return nil
                    }
                }
                
                onImageSelected(photos)
            }
            picker.dismiss(animated: true)
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate {
        
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
    }
}

extension YPMediaItem {
    func saveToFolder() throws -> TFile? {
        switch self {
        case .photo(let p):
            return try p.saveToFolder()
        case .video(let v):
            return try v.saveToFolder()
        }
    }
}

extension YPMediaPhoto {
    func saveToFolder() throws -> TFile? {
        guard let pngData = self.image.pngData() else {
            return nil
        }
        
        let imageName = "\(Date.now.timeIntervalSince1970).png"
        let item = TFile(fileName: imageName)
        
        let folderUrl = item.folderUrl
        if let cloudUrl = item.cloudUrl {
            try pngData.write(to: cloudUrl)
        }
        try pngData.write(to: folderUrl)
        
        return item
    }
}

extension YPMediaVideo {
    func saveToFolder() throws -> TFile? {
        let data = try Data(contentsOf: self.url)
        let fileName = self.url.lastPathComponent
        let item = TFile(fileName: fileName)
        let folderUrl = item.folderUrl
        if let cloudUrl = item.cloudUrl {
            try data.write(to: cloudUrl)
        }
        try data.write(to: folderUrl)
        
        return item
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    var sourceType: UIImagePickerController.SourceType
    var onImageSelected: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = context.coordinator
        return imagePicker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onImageSelected: onImageSelected)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var onImageSelected: (UIImage) -> Void

        init(onImageSelected: @escaping (UIImage) -> Void) {
            self.onImageSelected = onImageSelected
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let url = info[.imageURL] as? URL {
                if let image = url.asSmallImage {
                    onImageSelected(image)
                }
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }
}

import UniformTypeIdentifiers

extension URL {
    
    /// Used for limiting memory usage when opening new photos from user's library.
    ///
    /// Photos could consume a lot of memory when loaded into `UIImage`s. A 2000 by 2000 photo
    /// roughly will consume 2000 x 2000 x 4 bytes = 16MB. A 10 000 by 10 000 photo will consume
    /// 10000 * 10000 * 4 = 400MB which is a lot, give that in your app
    /// you could pick up more than one photo (consider picking 10-15 photos)
    var asSmallImage: UIImage? {
        
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        
        guard let source = CGImageSourceCreateWithURL(self as CFURL, sourceOptions) else { return nil }
        
        let downsampleOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: 2_000,
        ] as CFDictionary
        
        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, downsampleOptions) else { return nil }
        
        let data = NSMutableData()
        guard let imageDestination = CGImageDestinationCreateWithData(data, UTType.jpeg.identifier as CFString, 1, nil) else { return nil }
        
        // Don't compress PNGs, they're too pretty
        let destinationProperties = [kCGImageDestinationLossyCompressionQuality: cgImage.isPNG ? 1.0 : 0.75] as CFDictionary
        CGImageDestinationAddImage(imageDestination, cgImage, destinationProperties)
        CGImageDestinationFinalize(imageDestination)
        
        let image = UIImage(data: data as Data)
        return image
    }
}

extension CGImage {
    
    /// Gives info whether or not this `CGImage` represents a png image
    /// By observing its UT type.
    var isPNG: Bool {
        if #available(iOS 14.0, *) {
            return (utType as String?) == UTType.png.identifier
        } else {
            return (utType as String?) == UTType.jpeg.identifier
        }
    }
}
