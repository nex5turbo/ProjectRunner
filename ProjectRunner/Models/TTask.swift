//
//  File.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import Foundation

struct TTask: Identifiable, Hashable, Codable, Schedulable {
    var id: String = UUID().uuidString
    var name: String
    var superiorId: String?
    var dueDate: Date
    var status: Status = .todo
    var createdAt: Date
    var description: String
    var doneAt: Date?
    var markColor: MarkColor = .noColor
    var moments: [TMoment] = []
    var appointments: [TAppointment] = []
    var priority: Priority = .none
    var hasDeadline: Bool = false
    var imagePaths: [String] = []
    var labels: [TLabel] = []
    var taskIds: [String] = []
    
    var imageUrls: [URL] {
        return imagePaths.compactMap { path in
            return URL(string: path)
        }
    }
    
    static func emptyTask() -> TTask {
        return TTask(
            name: "",
            startDate: Date.now,
            dueDate: Date.now,
            createdAt: Date.now,
            description: ""
        )
    }

    init(name: String, startDate: Date, dueDate: Date, createdAt: Date, description: String) {
        self.name = name
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.description = description
    }
    
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case dueDate
        case superiorId = "projectId"
        case status
        case createdAt
        case description
        case moments
        case appointments
        case doneAt
        case priority
        case imagePaths
        case hasDeadline
        case markColor
        case labels
        case taskIds
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(String.self, forKey: .id)
        
        self.name = try container.decode(String.self, forKey: .name)
        
        self.superiorId = try container.decodeIfPresent(String.self, forKey: .superiorId)
        
        self.dueDate = try container.decode(Date.self, forKey: .dueDate)
        
        self.status = try container.decodeIfPresent(Status.self, forKey: .status) ?? Status.todo
        
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        
        self.description = try container.decode(String.self, forKey: .description)
        
        self.doneAt = try container.decodeIfPresent(Date.self, forKey: .doneAt)
        
        self.moments = (try? container.decode([TMoment].self, forKey: .moments)) ?? []
        
        self.appointments = (try? container.decode([TAppointment].self, forKey: .appointments)) ?? []
        
        self.priority = (try? container.decode(Priority.self, forKey: .priority)) ?? Priority.none
        
        self.hasDeadline = (try? container.decode(Bool.self, forKey: .hasDeadline)) ?? true
        
        self.imagePaths = (try? container.decode([String].self, forKey: .imagePaths)) ?? []
        
        self.markColor = (try? container.decode(MarkColor.self, forKey: .markColor)) ?? MarkColor.noColor
        
        self.labels = (try? container.decode([TLabel].self, forKey: .labels)) ?? []
        
        self.taskIds = (try? container.decode([String].self, forKey: .taskIds)) ?? []
    }
}
