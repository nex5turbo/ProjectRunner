//
//  File.swift
//  
//
//  Created by 워뇨옹 on 7/4/24.
//

import Foundation

struct TLabel: Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    var content: String
    
    enum CodingKeys: CodingKey {
        case id
        case content
    }
    init(_ content: String) {
        self.content = content
    }
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.content = try container.decode(String.self, forKey: .content)
    }
}
