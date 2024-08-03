//
//  TFile.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 8/2/24.
//

import Foundation

struct TFile: Codable, Identifiable, Equatable, Hashable {
    var id: String = UUID().uuidString
    var fileName: String
    var fileType: String
    var isExistInCloud: Bool {
        if let cloudUrl {
            return FileManager.default.fileExists(atPath: cloudUrl.path(percentEncoded: true))
        } else {
            return false
        }
    }
    
    var isExist: Bool {
        FileManager.default.fileExists(atPath: folderUrl.path(percentEncoded: true))
    }
    
    var fileExtension: String {
        String(fileName.split(separator: ".").last!)
    }
    
    var folderUrl: URL {
        switch fileType {
        case "images":
            return FileManager.default.imageFolder(fileName: fileName)
        case "videos":
            return FileManager.default.videoFolder(fileName: fileName)
        case "files":
            return FileManager.default.fileFolder(fileName: fileName)
        default:
            return FileManager.default.documentDirectory.appendingPathComponent(fileName)
        }
        
    }
    
    var cloudUrl: URL? {
        switch fileType {
        case "images":
            return FileManager.default.imageCloudFolder(fileName: fileName)
        case "videos":
            return FileManager.default.videoCloudFolder(fileName: fileName)
        case "files":
            return FileManager.default.fileCloudFolder(fileName: fileName)
        default:
            return FileManager.default.cloudDocumentDirectory?.appendingPathComponent(fileName)
        }
    }
    
    func delete() throws {
        print(folderUrl, cloudUrl)
        print(folderUrl.path(percentEncoded: true))
        print(cloudUrl?.path(percentEncoded: true))
        print(FileManager.default.fileExists(atPath: folderUrl.path))
        try FileManager.default.removeItem(at: folderUrl)
        if let cloudUrl {
            print(FileManager.default.fileExists(atPath: cloudUrl.path))
            try FileManager.default.removeItem(at: cloudUrl)
        }
        
    }
}
