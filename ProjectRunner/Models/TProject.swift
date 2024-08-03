//
//  File.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import Foundation

protocol Schedulable: Markable, FileAttachable {
    var id: String { get set }
    var description: String { get set }
    var name: String { get set}
    var moments: [TMoment] { get set }
    var appointments: [TAppointment] { get set }
    var dueDate: Date { get set }
    var doneAt: Date? { get set }
    var status: Status { get set }
    var createdAt: Date { get set }
    var priority: Priority { get set }
    var markColor: MarkColor { get set }
    var hasDeadline: Bool { get set }
    var labels: [TLabel] { get set }
    var taskIds: [String] { get set}
    func isIn(date: Date) -> Bool
    func isIn(dayItem: Day) -> Bool
    func contains(string: String) -> Bool
}

extension Schedulable {
    func contains(string: String) -> Bool {
        if string == "" {
            return true
        }
        if self.name.contains(string) || self.description.contains(string) ||
            !self.moments.filter({ moment in
                moment.comment.contains(string)
            }).isEmpty ||
            !self.appointments.filter({ event in
                event.comment.contains(string)
            }).isEmpty {
            return true
        } else {
            return false
        }
    }
    func isIn(dayItem: Day) -> Bool {
        if !hasDeadline {
            return true
        }
        guard let date = dayItem.toDate else {
            return false
        }
        return isIn(date: date)
    }
    func isIn(date: Date) -> Bool {
        if !hasDeadline {
            return true
        }
        return (createdAt...dueDate).contains(date)
    }
}

struct TProject: Identifiable, Hashable, Codable, Schedulable {
    var id: String = UUID().uuidString
    var name: String
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
    var priority: Priority = .none
    var files: [TFile] = []
    var labels: [TLabel] = []
    var hasDeadline: Bool = false
    
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
        self.dueDate = dueDate
        self.taskIds = taskIds
        self.createdAt = createdAt
        self.description = description
    }
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case dueDate
        case taskIds
        case clientIds
        case status
        case createdAt
        case description
        case moments
        case appointments
        case doneAt
        case priority
        case files
        case hasDeadline
        case markColor
        case labels
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(String.self, forKey: .id)
        
        self.name = try container.decode(String.self, forKey: .name)
        
        self.dueDate = try container.decode(Date.self, forKey: .dueDate)
        
        self.taskIds = (try? container.decode([String].self, forKey: .taskIds)) ?? []
        
        self.clientIds = (try? container.decode([String].self, forKey: .clientIds)) ?? []
        
        self.status = try container.decodeIfPresent(Status.self, forKey: .status) ?? Status.todo
        
        self.createdAt = try container.decode(Date.self, forKey: .createdAt)
        
        self.description = try container.decode(String.self, forKey: .description)
        
        self.moments = (try? container.decode([TMoment].self, forKey: .moments)) ?? []
        
        self.appointments = (try? container.decode([TAppointment].self, forKey: .appointments)) ?? []
        
        self.doneAt = try container.decodeIfPresent(Date.self, forKey: .doneAt)
        
        self.priority = (try? container.decode(Priority.self, forKey: .priority)) ?? Priority.none
        
        self.files = (try? container.decode([TFile].self, forKey: .files)) ?? []
        
        self.hasDeadline = (try? container.decode(Bool.self, forKey: .hasDeadline)) ?? true
        
        self.markColor = (try? container.decode(MarkColor.self, forKey: .markColor)) ?? MarkColor.noColor
        
        self.labels = (try? container.decode([TLabel].self, forKey: .labels)) ?? []
    }
}
