//
//  File.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import Foundation
import SwiftUI

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
    
    var systemName: String {
        return switch self {
        case .preparing:
            "circle.dotted"
        case .todo:
            "circle"
        case .inProgress:
            "play.circle"
        case .done:
            "checkmark.circle.fill"
        case .canceled:
            "xmark.circle.fill"
        }
    }
    
    var imageColor: Color {
        return switch self {
        case .preparing:
                .gray.opacity(0.5)
        case .todo:
                .black.opacity(0.8)
        case .inProgress:
                .yellow
        case .done:
                .pink
        case .canceled:
                .gray
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
