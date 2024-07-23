//
//  TDiary.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/19/24.
//

import Foundation

struct TDiary: Codable, Identifiable {
    var id: String = UUID().uuidString
    var createdAt: Date
    var createdDay: Day
    var content: String
    // 이모티콘 추가하기
}
