//
//  File.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import Foundation

protocol Markable {
    var markColor: MarkColor { get set }
}

protocol Notifiable: Identifiable {
    var id: String { get set }
    var hasNotification: Bool { get set }
    var comment: String { get set }
    var notifyAt: Date { get set }
    var shouldRepeat: Bool { get set }
    
    func setNotification(with schedule: Schedulable)
    func setNotification()
    func disableNotification()
}

struct TMoment: Identifiable, Hashable, Codable {
    var id: String = UUID().uuidString
    var comment: String
    var isDone: Bool = false
    var createdAt: Date
    
    init() {
        self.comment = ""
        self.createdAt = Date.now
    }
    
    enum CodingKeys: CodingKey {
        case id
        case comment
        case isDone
        case createdAt
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.comment = try container.decode(String.self, forKey: .comment)
        self.isDone = (try? container.decode(Bool.self, forKey: .isDone)) ?? false
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
}

struct TAppointment: Hashable, Codable, Notifiable {
    var id: String = UUID().uuidString
    var comment: String
    var isDone: Bool = false
    var notifyAt: Date
    var hasNotification: Bool = false
    var shouldRepeat: Bool = false
    var createdAt: Date
    var members: [TClient] = []
    
    enum CodingKeys: CodingKey {
        case id
        case comment
        case isDone
        case notifyAt
        case hasNotification
        case shouldRepeat
        case createdAt
        case members
    }
    
    init() {
        self.comment = ""
        self.notifyAt = Date.now
        self.createdAt = Date.now
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        self.comment = try container.decode(String.self, forKey: .comment)
        self.isDone = (try? container.decode(Bool.self, forKey: .isDone)) ?? false
        self.notifyAt = try container.decode(Date.self, forKey: .notifyAt)
        self.hasNotification = try container.decode(Bool.self, forKey: .hasNotification)
        self.shouldRepeat = try container.decode(Bool.self, forKey: .shouldRepeat)
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        self.members = try container.decode([TClient].self, forKey: .members)
    }
    
    func setNotification() {
        NotificationManager.instance.simpleNotification(notification: self)
    }
    
    func disableNotification() {
        NotificationManager.instance.cancelNotification(notification: self)
    }
    
    func setNotification(with schedule: any Schedulable) {
        NotificationManager.instance.scheduleNotification(schedule: schedule, notification: self)
    }
}
