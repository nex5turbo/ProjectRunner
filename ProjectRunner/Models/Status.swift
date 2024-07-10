//
//  File.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import Foundation

enum Status: String, Codable, CaseIterable {
    
    case preparing
    case todo
    case inProgress
    case done
    case canceled
    
    static func listForSort() -> [Status] {
        return [Status.inProgress, Status.todo, Status.preparing, Status.done, Status.canceled]
    }
    
    var title: String {
        return switch self {
        case .preparing:
            "Preparing"
        case .todo:
            "Todo"
        case .inProgress:
            "In Progress"
        case .done:
            "Done"
        case .canceled:
            "Canceled"
        }
    }
    var emoji: String {
        return switch self {
        case .preparing:
            ""
        case .todo:
            ""
        case .inProgress:
            ""
        case .done:
            ""
        case .canceled:
            ""
        }
    }
}
