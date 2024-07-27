//
//  AppData.swift
//  ProjectRunnerWidgetExtension
//
//  Created by 워뇨옹 on 7/16/24.
//

import Foundation

struct AppData: Codable {
    var projects: [TProject]
    var tasks: [TTask]
}

struct TProject: Codable {
    var id: String
    var name: String
    var dueDate: Date
    var hasDeadline: Bool
    var status: Status
    var priority: Priority
    var markColor: MarkColor
    var taskIds: [String]
}

struct TTask: Codable {
    var id: String
    var name: String
    var dueDate: Date
    var hasDeadline: Bool
    var status: Status
    var priority: Priority
    var markColor: MarkColor
    var taskIds: [String]
}
