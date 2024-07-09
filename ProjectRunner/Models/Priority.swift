//
//  File.swift
//
//
//  Created by 워뇨옹 on 6/28/24.
//

import Foundation

enum Priority: String, Codable, CaseIterable {
    case urgent
    case high
    case medium
    case low
    case none
    
    var imageName: String {
        switch self {
        case .urgent:
            ""
        case .high:
            ""
        case .medium:
            ""
        case .low:
            ""
        case .none:
            ""
        }
    }
    
    var level: Int {
        return switch self {
        case .urgent:
            5
        case .high:
            4
        case .medium:
            3
        case .low:
            2
        case .none:
            1
        }
    }
    
    var title: String {
        return switch self {
        case .urgent:
            "Urgent"
        case .high:
            "High"
        case .medium:
            "Medium"
        case .low:
            "Low"
        case .none:
            "No Priority"
        }
    }
}
