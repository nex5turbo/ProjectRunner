//
//  ProjectRunnerWidget.swift
//  ProjectRunnerWidget
//
//  Created by 워뇨옹 on 7/16/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent(), appData: AppData(projects: [], tasks: []))
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration, appData: AppData(projects: [], tasks: []))
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        let groupFolder = FileManager.default.sharedDirectory?.appendingPathComponent("AppData.tm")
        if let groupFolder {
            if let data = try? Data(contentsOf: groupFolder) {
                let decoder = JSONDecoder()
                if let json = try? decoder.decode(AppData.self, from: data) {
                    var appData: AppData = json

                    var entries: [SimpleEntry] = []
                    let entry = Entry(date: Date.now, configuration: configuration, appData: appData)
                    entries.append(entry)

                    return Timeline(entries: entries, policy: .atEnd)
                }
            }
        }
        return Timeline(entries: [], policy: .never)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let appData: AppData
}

struct ProjectRunnerWidgetEntryView : View {
    var entry: Provider.Entry
    var preparingTasks: [TTask] {
        entry.appData.tasks.filter { $0.status == .preparing }
    }
    var todoTasks: [TTask] {
        entry.appData.tasks.filter { $0.status == .todo }
    }
    var inProgressTasks: [TTask] {
        entry.appData.tasks.filter { $0.status == .inProgress }
    }
    var doneTasks: [TTask] {
        entry.appData.tasks.filter { $0.status == .done }
    }
    var canceledTasks: [TTask] {
        entry.appData.tasks.filter { $0.status == .canceled }
    }
    var todoTask: [TTask] {
        entry.appData.tasks.filter {
            [Status.todo, Status.inProgress, Status.preparing].contains($0.status) &&
            $0.hasDeadline
        }
    }
    var sortedTasks: [TTask] {
        Array(todoTask.sorted(by: { $0.dueDate < $1.dueDate} ).prefix(3))
    }
    var body: some View {
        VStack(alignment: .leading) {
            Text("Tasks")
                .font(.subheadline)
            Divider()
            ForEach(sortedTasks, id: \.self) { task in
                Text(task.name)
                    .lineLimit(1)
                    .font(.caption2)
                Divider()
            }
            Spacer()
        }
        .containerBackground(.yellow.opacity(0.3), for: .widget)
    }
}

struct ProjectRunnerWidget: Widget {
    let kind: String = "ProjectRunnerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            ProjectRunnerWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
    }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    ProjectRunnerWidget()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley, appData: AppData(projects: [], tasks: []))
    SimpleEntry(date: .now, configuration: .starEyes, appData: AppData(projects: [], tasks: []))
}
