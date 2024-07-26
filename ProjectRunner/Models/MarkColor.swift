//
//  File.swift
//  
//
//  Created by 워뇨옹 on 7/2/24.
//

import Foundation
import SwiftUI

enum MarkColor: String, Codable, CaseIterable {
    case noColor
    case red
    case blue
    case yellow
    case teal
    case orange
    case green
    case purple
    
    var textColor: Color {
        switch self {
        case .noColor:
                .black
        default:
                .white
        }
    }
    
    var title: String {
        switch self {
        case .noColor:
            "white"
        case .red:
            "red"
        case .blue:
            "blue"
        case .yellow:
            "yellow"
        case .teal:
            "teal"
        case .orange:
            "orange"
        case .green:
            "green"
        case .purple:
            "purple"
        }
    }
    
    var color: Color {
        switch self {
        case .noColor:
                .white
        case .red:
                .red
        case .blue:
                .blue
        case .yellow:
                .yellow
        case .teal:
                .teal
        case .orange:
                .orange
        case .green:
                .green
        case .purple:
                .purple
        }
    }
}
