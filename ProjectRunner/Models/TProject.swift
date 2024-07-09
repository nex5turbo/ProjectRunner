//
//  File.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import Foundation

protocol Schedulable: Markable {
    var id: String { get set }
    var name: String { get set}
    var moments: [TMoment] { get set }
    var appointments: [TAppointment] { get set }
    var startDate: Date { get set }
    var dueDate: Date { get set }
    var doneAt: Date? { get set }
    var status: Status { get set }
    var canceledAt: Date? { get set }
    var priority: Priority { get set }
    var imagePaths: [String] { get set }
    var imageUrls: [URL] { get }
    var markColor: MarkColor { get set }
    var hasDeadline: Bool { get set }
    var labels: [TLabel] { get set }
    var taskIds: [String] { get set}
}

struct TProject: Identifiable, Hashable, Codable, Schedulable {
    var id: String = UUID().uuidString
    var name: String
    var startDate: Date
    var dueDate: Date
    var taskIds: [String]
    var clientIds: [String] = []
    var status: Status = .todo
    var createdAt: Date
    var description: String
    var moments: [TMoment] = []
    var appointments: [TAppointment] = []
    var markColor: MarkColor = .noColor
    var doneAt: Date?
    var canceledAt: Date?
    var priority: Priority = .none
    var imagePaths: [String] = []
    var labels: [TLabel] = []
    var hasDeadline: Bool = false
    var imageUrls: [URL] {
        return imagePaths.compactMap { path in
            return URL(string: path)
        }
    }
    
    static func empty() -> Self {
        return TProject(
            name: "",
            startDate: Date.now,
            dueDate: Date.now,
            taskIds: [],
            createdAt: Date.now,
            description: ""
        )
    }
    
    init(name: String, startDate: Date, dueDate: Date, taskIds: [String], createdAt: Date, description: String) {
        self.name = name
        self.startDate = startDate
        self.dueDate = dueDate
        self.taskIds = taskIds
        self.createdAt = createdAt
        self.description = description
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case startDate
        case dueDate
        case taskIds
        case clientIds
        case status
        case createdAt
        case description
        case moments
        case appointments
        case doneAt
        case canceledAt
        case priority
        case imagePaths
        case hasDeadline
        case markColor
        case labels
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        self.name = try container.decode(String.self, forKey: .name)
        
        self.startDate = try container.decode(Date.self, forKey: .startDate)
        
        self.dueDate = try container.decode(Date.self, forKey: .dueDate)
        
        self.taskIds = (try? container.decode([String].self, forKey: .taskIds)) ?? []
        
        self.clientIds = (try? container.decode([String].self, forKey: .clientIds)) ?? []
        
        self.status = try container.decodeIfPresent(Status.self, forKey: .status) ?? Status.todo
        
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        
        self.description = try container.decode(String.self, forKey: .description)
        
        self.moments = (try? container.decode([TMoment].self, forKey: .moments)) ?? []
        
        self.appointments = (try? container.decode([TAppointment].self, forKey: .appointments)) ?? []
        
        self.doneAt = try container.decodeIfPresent(Date.self, forKey: .doneAt)
        
        self.canceledAt = try container.decodeIfPresent(Date.self, forKey: .canceledAt)
        
        self.priority = (try? container.decode(Priority.self, forKey: .priority)) ?? Priority.none
        
        self.imagePaths = (try? container.decode([String].self, forKey: .imagePaths)) ?? []
        
        self.hasDeadline = (try? container.decode(Bool.self, forKey: .hasDeadline)) ?? true
        
        self.markColor = (try? container.decode(MarkColor.self, forKey: .markColor)) ?? MarkColor.noColor
        self.labels = (try? container.decode([TLabel].self, forKey: .labels)) ?? []
    }
}
