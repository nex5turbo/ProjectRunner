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
