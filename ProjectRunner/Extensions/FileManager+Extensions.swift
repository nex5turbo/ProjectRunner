//
//  FileManager+Extensions.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/16/24.
//

import Foundation

extension FileManager {
    var documentDirectory: URL {
        urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    var cloudDocumentDirectory: URL? {
        url(forUbiquityContainerIdentifier: nil)?.appendingPathComponent("Documents")
    }
    
    var sharedDirectory: URL? {
        containerURL(forSecurityApplicationGroupIdentifier: "group.ProjectRunner")
    }
    
    func imageFolder(fileName: String? = nil) -> URL {
        let imageFolder = documentDirectory.appendingPathComponent("images")
        if !fileExists(atPath: imageFolder.path()) {
            try? createDirectory(at: imageFolder, withIntermediateDirectories: true)
        }
        if let fileName {
            return imageFolder.appendingPathComponent(fileName)
        } else {
            return imageFolder
        }
    }
    
    func imageCloudFolder(fileName: String? = nil) -> URL? {
        guard let imageFolder = cloudDocumentDirectory?.appendingPathComponent("images") else {
            return nil
        }
        if !fileExists(atPath: imageFolder.path()) {
            try? createDirectory(at: imageFolder, withIntermediateDirectories: true)
        }
        if let fileName {
            return imageFolder.appendingPathComponent(fileName)
        } else {
            return imageFolder
        }
    }
    
    func videoFolder(fileName: String? = nil) -> URL {
        let imageFolder = documentDirectory.appendingPathComponent("videos")
        if !fileExists(atPath: imageFolder.path()) {
            try? createDirectory(at: imageFolder, withIntermediateDirectories: true)
        }
        if let fileName {
            return imageFolder.appendingPathComponent(fileName)
        } else {
            return imageFolder
        }
    }
    
    func videoCloudFolder(fileName: String? = nil) -> URL? {
        guard let imageFolder = cloudDocumentDirectory?.appendingPathComponent("videos") else {
            return nil
        }
        if !fileExists(atPath: imageFolder.path()) {
            try? createDirectory(at: imageFolder, withIntermediateDirectories: true)
        }
        if let fileName {
            return imageFolder.appendingPathComponent(fileName)
        } else {
            return imageFolder
        }
    }
    
    func fileFolder(fileName: String? = nil) -> URL {
        let imageFolder = documentDirectory.appendingPathComponent("files")
        if !fileExists(atPath: imageFolder.path()) {
            try? createDirectory(at: imageFolder, withIntermediateDirectories: true)
        }
        if let fileName {
            return imageFolder.appendingPathComponent(fileName)
        } else {
            return imageFolder
        }
    }
    
    func fileCloudFolder(fileName: String? = nil) -> URL? {
        guard let imageFolder = cloudDocumentDirectory?.appendingPathComponent("files") else {
            return nil
        }
        if !fileExists(atPath: imageFolder.path()) {
            try? createDirectory(at: imageFolder, withIntermediateDirectories: true)
        }
        if let fileName {
            return imageFolder.appendingPathComponent(fileName)
        } else {
            return imageFolder
        }
    }
}
