//
//  Strings.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/27/24.
//

import Foundation

extension String {
    static let createMoreTasks: String = "Subscribe and manage more than 10 tasks per project!"
    static let createMoreProjects: String = "Subscribe and manage more than 3 projects!"
    static let createMoreDiaries: String = "Subscribe and save more than 10 diaries!"
    
    static func createMoreTasks(_ projectName: String) -> String {
        return "\(projectName) has reached to limit! Subscribe and manage more than 10 tasks on \(projectName)"
    }
}

extension String {
    func linkify() -> AttributedString {
        let text = self
        var attributedString = AttributedString(text)
        let pattern = "(https://[\\S]+)(?=\\s|$)"
        
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let nsRange = NSRange(text.startIndex..<text.endIndex, in: text)
            
            for match in regex.matches(in: text, options: [], range: nsRange) {
                if let range = Range(match.range(at: 1), in: text) {
                    let urlString = String(text[range])
                    if let url = URL(string: urlString) {
                        let startIndex = AttributedString.Index(range.lowerBound, within: attributedString)
                        let endIndex = AttributedString.Index(range.upperBound, within: attributedString)
                        
                        if let startIndex = startIndex, let endIndex = endIndex {
                            attributedString[startIndex..<endIndex].link = url
                        }
                    }
                }
            }
        }
        
        return attributedString
    }
}
