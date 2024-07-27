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
}
