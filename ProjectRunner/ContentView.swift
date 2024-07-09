//
//  ContentView.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/9/24.
//

import SwiftUI


enum Tab : String, Hashable {
    case project, task, client, settings
}

struct ContentView: View {
    
    @AppStorage("tab") var tab = Tab.project
    @State private var appData: AppData = AppData()

    var body: some View {
        TabView(selection: $tab) {
            NavigationStack {
                ProjectView(
                    appData: $appData
                )
            }
            .tabItem { Label("Project", systemImage: "square.stack.3d.up.fill") }
            .tag(Tab.project)
            
            NavigationStack {
                TaskView(
                    appData: $appData
                )
            }
            .tabItem { Label("Task", systemImage: "bookmark.fill") }
            .tag(Tab.task)
            
            NavigationStack {
                ClientView(
                    appData: $appData
                )
            }
            .tabItem { Label("Contact", systemImage: "person.fill") }
            .tag(Tab.client)
            
            NavigationStack {
                SettingsView(appData: $appData)
            }
            .tabItem { Label("Setting", systemImage: "gearshape.fill") }
            .tag(Tab.settings)
        }
        .preferredColorScheme(.light)
        .task {
            do {
                let folder = try FileManager.default.url(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("AppData.tm")
                if FileManager.default.fileExists(atPath: folder.path) {
                    let data = try Data(contentsOf: folder)
                    let decoder = JSONDecoder()
                    let appData = try decoder.decode(AppData.self, from: data)
                    self.appData = appData
                } else {
                    print("file not found")
                }
            } catch {
                print("Reason: ",error.localizedDescription)
            }
        }
    }
}

#Preview {
    ContentView()
}
