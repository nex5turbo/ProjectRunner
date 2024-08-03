//
//  TDiary.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/19/24.
//

import Foundation

struct TDiary: Codable, Identifiable, Hashable, FileAttachable {
    var id: String = UUID().uuidString
    var createdAt: Date
    var createdDay: Day
    var content: String
    var files: [TFile] = []
    
    init(createdAt: Date, createdDay: Day, content: String) {
        self.createdDay = createdDay
        self.createdAt = createdAt
        self.content = content
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.createdDay = try container.decode(Day.self, forKey: .createdDay)
        self.content = try container.decode(String.self, forKey: .content)
        self.files = (try? container.decode([TFile].self, forKey: .files)) ?? []
    }
}
