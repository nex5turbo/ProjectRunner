//
//  File.swift
//
//
//  Created by 워뇨옹 on 6/27/24.
//

import Foundation

struct AppData: Codable, Hashable {
    var tasks: [TTask]
    var projects: [TProject]
    var clients: [TClient]
    var labels: [TLabel]
    var clientLabels: [TLabel]
    
    var sortedTasks: [TTask] {
        self.tasks.sorted { $0.createdAt > $1.createdAt }
    }
    
    var sortedProjects: [TProject] {
        self.projects.sorted { $0.createdAt > $1.createdAt }
    }
    
    enum CodingKeys: CodingKey {
        case tasks
        case projects
        case clients
        case labels
        case clientLabels
    }
    
    init() {
        self.tasks = []
        self.projects = []
        self.clients = []
        self.labels = [
            .init("💪Work out"),
            .init("📚Study"),
            .init("🧑‍💻Development"),
            .init("🎨Design")
        ]
        self.clientLabels = [
            .init("👨‍🏫teacher"),
            .init("👩manager"),
            .init("🧑‍💻team member"),
            .init("👨‍🦱Client")
        ]
    }
    let defaultClientLabels: [TLabel] = [
        .init("👨‍🏫teacher"),
        .init("👩manager"),
        .init("🧑‍💻team member"),
        .init("👨‍🦱Client")
    ]
    
    let defaultLabels: [TLabel] = [
        .init("💪Work out"),
        .init("📚Study"),
        .init("🧑‍💻Development"),
        .init("🎨Design")
    ]
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.tasks = try container.decode([TTask].self, forKey: .tasks)
        self.projects = try container.decode([TProject].self, forKey: .projects)
        self.clients = try container.decode([TClient].self, forKey: .clients)
        
        self.clientLabels = (try? container.decode([TLabel].self, forKey: .clientLabels)) ?? defaultClientLabels
        self.labels = (try? container.decode([TLabel].self, forKey: .labels)) ?? defaultLabels
    }
    
    func save() throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = JSONEncoder.OutputFormatting.prettyPrinted
        
        let data = try encoder.encode(self)
        let folder = FileManager.default.documentDirectory.appendingPathComponent("AppData.tm")
        let iCloudFolder = FileManager.default.cloudDocumentDirectory?.appendingPathComponent("AppData.tm")
        let groupFolder = FileManager.default.sharedDirectory?.appendingPathComponent("AppData.tm")
        try data.write(to: folder)
        if let iCloudFolder {
            try data.write(to: iCloudFolder)
        }
        if let groupFolder {
            try data.write(to: groupFolder)
        }
        
        return
    }
    
    mutating func loadTutorial() throws {
        guard let url = Bundle.main.url(forResource: "tutorial", withExtension: "json") else {
            return
        }
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let appData = try decoder.decode(AppData.self, from: data)
        
        self.projects.append(contentsOf: appData.projects)
        self.tasks.append(contentsOf: appData.tasks)
        if self.labels.isEmpty {
            self.labels.append(contentsOf: appData.labels)
        }
        if self.clients.isEmpty {
            self.clients.append(contentsOf: appData.clients)
        }
        if self.clientLabels.isEmpty {
            self.clientLabels.append(contentsOf: appData.clientLabels)
        }
    }
}

extension AppData {
    func getSuperior(of task: TTask) -> Schedulable? {
        if let superior = tasks.first(where: { $0.id == task.superiorId }) {
            return superior
        }
        if let superior = projects.first(where: { $0.id == task.superiorId }) {
            return superior
        }
        return nil
    }
    
    func getSuperior(of id: String) -> Schedulable? {
        if let superior = tasks.first(where: { $0.id == id }) {
            return superior
        }
        if let superior = projects.first(where: { $0.id == id }) {
            return superior
        }
        return nil
    }
}

/// label functions
extension AppData {
    mutating func setLabel(schedule: Schedulable, labels: [TLabel]) throws {
        if let task = schedule as? TTask {
            guard let index = tasks.firstIndex(where: { task.id == $0.id }) else {
                return
            }
            tasks[index].labels = labels
        } else if let project = schedule as? TProject {
            guard let index = projects.firstIndex(where: { project.id == $0.id }) else {
                return
            }
            projects[index].labels = labels
        }
        try save()
    }
}

/// appointment functions
extension AppData {
    
    mutating func addAppointment(task: TTask, appointment: TAppointment) throws {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        if let appointmentIndex = task.appointments.firstIndex(where: { $0.id == appointment.id }) {
            tasks[index].appointments[appointmentIndex] = appointment
        } else {
            tasks[index].appointments.append(appointment)
        }

        try save()
    }
    
    mutating func addAppointment(project: TProject, appointment: TAppointment) throws {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else {
            return
        }
        if let appointmentIndex = project.appointments.firstIndex(where: { $0.id == appointment.id }) {
            projects[index].appointments[appointmentIndex] = appointment
        } else {
            projects[index].appointments.append(appointment)
        }
        
        try save()
    }
    
    mutating func addAppointment(schedule: Schedulable, appintment: TAppointment) throws {
        if let task = schedule as? TTask {
            try addAppointment(task: task, appointment: appintment)
        } else if let project = schedule as? TProject {
            try addAppointment(project: project, appointment: appintment)
        }

        if appintment.hasNotification {
            NotificationManager.instance.scheduleNotification(schedule: schedule, notification: appintment)
        } else {
            NotificationManager.instance.cancelNotification(notification: appintment)
        }
    }
    
    mutating func removeAppointment(schedule: Schedulable, appointment: TAppointment) throws {
        if let task = schedule as? TTask {
            guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
                return
            }
            tasks[index].appointments.removeAll(where: { $0.id == appointment.id })
        } else if let project = schedule as? TProject {
            guard let index = projects.firstIndex(where: { $0.id == project.id }) else {
                return
            }
            projects[index].appointments.removeAll(where: { $0.id == appointment.id })
        }

        NotificationManager.instance.cancelNotification(notification: appointment)

        try save()
    }
}

/// moment functions
extension AppData {
    mutating func addMoment(task: TTask, moment: TMoment) throws {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        
        if let momentIndex = task.moments.firstIndex(where: { $0.id == moment.id }) {
            tasks[index].moments[momentIndex] = moment
        } else {
            tasks[index].moments.append(moment)
        }
        
        try save()
    }
    mutating func addMoment(project: TProject, moment: TMoment) throws {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else {
            return
        }
        
        if let momentIndex = project.moments.firstIndex(where: { $0.id == moment.id }) {
            projects[index].moments[momentIndex] = moment
        } else {
            projects[index].moments.append(moment)
        }
        
        try save()
    }
    
    mutating func addMoment(schedule: Schedulable, moment: TMoment) throws {
        if let task = schedule as? TTask {
            try addMoment(task: task, moment: moment)
        } else if let project = schedule as? TProject {
            try addMoment(project: project, moment: moment)
        }
        return
    }
    

    
    mutating func removeMoment(schedule: Schedulable, moment: TMoment) throws {
        if let task = schedule as? TTask {
            guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
                return
            }
            tasks[index].moments.removeAll(where: { $0.id == moment.id })
        } else if let project = schedule as? TProject {
            guard let index = projects.firstIndex(where: { $0.id == project.id }) else {
                return
            }
            projects[index].moments.removeAll(where: { $0.id == moment.id })
        }
        try save()
    }
}


/// status functions
extension AppData {
    mutating func setStatus(schedule: Schedulable, to status: Status) throws {
        if let task = schedule as? TTask {
            try setTaskStatus(task: task, to: status)
        } else if let project = schedule as? TProject {
            try setProjectStatus(project: project, to: status)
        }
    }
    
    mutating func setProjectStatus(project: TProject, to status: Status) throws {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else {
            return
        }
        
        guard project.status != status else {
            return
        }
        
        projects[index].status = status
        try save()
    }
    
    mutating func setTaskStatus(task: TTask, to status: Status) throws {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        guard task.status != status else {
            return
        }
        tasks[index].status = status
        try save()
    }
}

/// priority functions
extension AppData {
    
    mutating func setPriority(schedule: Schedulable, to priority: Priority) throws {
        if let task = schedule as? TTask {
            try setTaskPriority(task: task, to: priority)
        } else if let project = schedule as? TProject {
            try setProjectPriority(project: project, to: priority)
        }
    }
    
    mutating func setProjectPriority(project: TProject, to priority: Priority) throws {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else {
            return
        }
        
        projects[index].priority = priority
        try save()
    }
    
    mutating func setTaskPriority(task: TTask, to priority: Priority) throws {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        
        tasks[index].priority = priority
        try save()
    }
}

/// add functions
extension AppData {
    
    mutating func addTask(task: TTask) throws {
        if let projectIndex = self.projects.firstIndex(where: { $0.id == task.superiorId }) {
            if !projects[projectIndex].taskIds.contains(task.id) {
                projects[projectIndex].taskIds.append(task.id)
            }
        }
        
        if let taskIndex = self.tasks.firstIndex(where: { $0.id == task.superiorId }) {
            if !tasks[taskIndex].taskIds.contains(task.id) {
                tasks[taskIndex].taskIds.append(task.id)
            }
        }
        
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            return try self.save()
        }
        tasks.append(task)
        return try self.save()
    }
    
    mutating func addClient(client: TClient) throws {
        if let index = clients.firstIndex(where: {$0.id == client.id}) {
            clients[index] = client
            return try self.save()
        }
        clients.append(client)
        return try self.save()
    }
    
    mutating func addProject(project: TProject) throws {
        if let index = projects.firstIndex(where: { $0.id == project.id }) {
            projects[index] = project
            return try self.save()
        }
        projects.append(project)
        return try self.save()
    }
}

/// delete functions
extension AppData {
    
    mutating func delete(schedule: Schedulable, shouldDeleteSubTasks: Bool = false) throws {
        if let task = schedule as? TTask {
            try deleteTask(task: task, shouldDeleteSubTasks: shouldDeleteSubTasks)
        } else if let project = schedule as? TProject {
            try deleteProject(project: project, shouldDeleteSubTasks: shouldDeleteSubTasks)
        } else {
            return
        }
    }
    
    mutating func deleteTask(task: TTask, shouldDeleteSubTasks: Bool = false) throws {
        guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        if let projectIndex = projects.firstIndex(where: { $0.id == task.superiorId }) {
            projects[projectIndex].taskIds.removeAll(where: { $0 == task.id })
        }
        if let taskIndex = tasks.firstIndex(where: { $0.id == task.superiorId }) {
            tasks[taskIndex].taskIds.removeAll(where: { $0 == task.id })
        }
        if shouldDeleteSubTasks {
            let subTasks: [TTask] = self.tasks.filter { task.taskIds.contains($0.id) }
            subTasks.forEach { subTask in
                try? deleteTask(task: subTask, shouldDeleteSubTasks: true)
            }
        } else {
            tasks.enumerated().forEach { (index, _task) in
                if _task.superiorId == task.id {
                    tasks[index].superiorId = nil
                }
            }
        }
        
        tasks.remove(at: index)
        do {
            try save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    mutating func deleteProject(project: TProject, shouldDeleteSubTasks: Bool = false) throws {
        guard let index = projects.firstIndex(where: { $0.id == project.id }) else {
            return
        }
        if shouldDeleteSubTasks {
            let subTasks: [TTask] = self.tasks.filter { project.taskIds.contains($0.id) }
            subTasks.forEach { subTask in
                try? deleteTask(task: subTask, shouldDeleteSubTasks: true)
            }
        } else {
            tasks.enumerated().forEach { (index, task) in
                if task.superiorId == project.id {
                    tasks[index].superiorId = nil
                }
            }
        }
        projects.remove(at: index)
        do {
            try save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    mutating func deleteClient(client: TClient) throws {
        guard let index = clients.firstIndex(where: { $0.id == client.id }) else {
            return
        }
        projects.enumerated().forEach { (pindex, _) in
            projects[pindex].clientIds.removeAll(where: { $0 == client.id })
        }
        clients.remove(at: index)
        try save()
    }
}

/// modify functions
extension AppData {
    mutating func changeName(schedule: Schedulable, to name: String) throws {
        if let task = schedule as? TTask {
            guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
                return
            }
            tasks[index].name = name
        } else if let project = schedule as? TProject {
            guard let index = projects.firstIndex(where: { $0.id == project.id }) else {
                return
            }
            projects[index].name = name
        }
        try save()
    }
    
    mutating func changeDescription(schedule: Schedulable, to description: String) throws {
        if let task = schedule as? TTask {
            guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
                return
            }
            tasks[index].description = description
        } else if let project = schedule as? TProject {
            guard let index = projects.firstIndex(where: { $0.id == project.id }) else {
                return
            }
            projects[index].description = description
        }
        try save()
    }
    
    mutating func changeStartDate(schedule: Schedulable, to startDate: Date) throws {
        if let task = schedule as? TTask {
            guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
                return
            }
            tasks[index].startDate = startDate
        } else if let project = schedule as? TProject {
            guard let index = projects.firstIndex(where: { $0.id == project.id }) else {
                return
            }
            projects[index].startDate = startDate
        }
        
        try save()
    }
    
    mutating func changeDueDate(schedule: Schedulable, _ hasDueDate: Bool, to dueDate: Date) throws {
        if let task = schedule as? TTask {
            guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
                return
            }
            tasks[index].hasDeadline = hasDueDate
            tasks[index].dueDate = dueDate
        } else if let project = schedule as? TProject {
            guard let index = projects.firstIndex(where: { $0.id == project.id }) else {
                return
            }
            projects[index].hasDeadline = hasDueDate
            projects[index].dueDate = dueDate
        }
        try save()
    }
    
    mutating func changeSuperior(task: TTask, to superior: Schedulable) throws {
        
        guard let taskIndex = tasks.firstIndex(where: { $0.id == task.id }) else {
            return
        }
        
        if let superiorId = task.superiorId, let superiorIndex = tasks.firstIndex(where: { $0.id == superiorId }) {
            tasks[superiorIndex].taskIds.removeAll(where: { $0 == task.id })
        }
        if let superiorId = task.superiorId, let superiorIndex = projects.firstIndex(where: { $0.id == superiorId }) {
            projects[superiorIndex].taskIds.removeAll(where: { $0 == task.id })
        }

        if let superiorIndex = projects.firstIndex(where: { $0.id == superior.id }) {
            projects[superiorIndex].taskIds.append(task.id)
            tasks[taskIndex].superiorId = superior.id
        } else if let superiorIndex = tasks.firstIndex(where: { $0.id == superior.id }) {
            tasks[superiorIndex].taskIds.append(task.id)
            tasks[taskIndex].superiorId = superior.id
        } else {
            return
        }
        
        try save()
    }
    
    mutating func changeProjectMembers(project: TProject, to members: [TClient]) throws {
        guard let index = projects.firstIndex(where: { project.id == $0.id }) else {
            return
        }
        projects[index].clientIds = members.map { $0.id }
        
        try save()
    }
    
    mutating func changeColor(schedule: Schedulable, to markColor: MarkColor) throws {
        if let task = schedule as? TTask {
            guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
                return
            }
            tasks[index].markColor = markColor
        } else if let project = schedule as? TProject {
            guard let index = projects.firstIndex(where: { $0.id == project.id }) else {
                return
            }
            projects[index].markColor = markColor
        }
        
        try save()
    }
    
    mutating func changeSubTasks(schedule: Schedulable, with taskIds: [String]) throws {
        if let task = schedule as? TTask {
            guard let index = tasks.firstIndex(where: { $0.id == task.id }) else {
                return
            }
            taskIds.forEach { id in
                guard let newIndex = tasks.firstIndex(where: { $0.id == id }) else {
                    return
                }
                let newTask = tasks[newIndex]
                if newTask.superiorId != nil {
                    // superior의 taskIds에서 newTask id 지우기
                    if let supIndex = tasks.firstIndex(where: { ctask in
                        ctask.taskIds.contains(where: { $0 == id })
                    }) {
                        tasks[supIndex].taskIds.removeAll(where: { $0 == id })
                    } else if let supIndex = projects.firstIndex(where: { ctask in
                        ctask.taskIds.contains(where: { $0 == id })
                    }) {
                        projects[supIndex].taskIds.removeAll(where: { $0 == id })
                    }
                }
                tasks[newIndex].superiorId = schedule.id
            }
            tasks[index].taskIds = taskIds
        } else if let project = schedule as? TProject {
            guard let index = projects.firstIndex(where: { $0.id == project.id }) else {
                return
            }
            taskIds.forEach { id in
                guard let newIndex = tasks.firstIndex(where: { $0.id == id }) else {
                    return
                }
                let newTask = tasks[newIndex]
                if newTask.superiorId != nil {
                    // superior의 taskIds에서 newTask id 지우기
                    if let supIndex = tasks.firstIndex(where: { ctask in
                        ctask.taskIds.contains(where: { $0 == id })
                    }) {
                        tasks[supIndex].taskIds.removeAll(where: { $0 == id })
                    } else if let supIndex = projects.firstIndex(where: { ctask in
                        ctask.taskIds.contains(where: { $0 == id })
                    }) {
                        projects[supIndex].taskIds.removeAll(where: { $0 == id })
                    }
                }
                tasks[newIndex].superiorId = schedule.id
            }
            projects[index].taskIds = taskIds
        }
        
        try save()
    }
}
