//
//  ContentView.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/9/24.
//

import SwiftUI
import WidgetKit

enum Tab : String, Hashable {
    case project, task, calendar, client, settings
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("isFirst") var isFirst = true
    @AppStorage("tab") var tab = Tab.project
    
    @ObservedObject var purchaseManager: PurchaseManager = PurchaseManager.shared
    @State private var appData: AppData = AppData()
    @State private var isError: Bool = false
    init() {
        UITabBar.appearance().backgroundColor = UIColor.white
    }
    var body: some View {
        ZStack {
            if isError {
                VStack {
                    Text("Error has occured")
                        .font(.headline)
                    Button {
                        self.loadAppData()
                    } label: {
                        Text("Refresh")
                            .font(.footnote)
                    }
                }
            } else {
                
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
                    .tabItem { Label("Task", systemImage: "list.bullet") }
                    .tag(Tab.task)
                    
                    NavigationStack {
                        CalenderView(appData: $appData)
                    }
                    .tabItem { Label("Calendar", systemImage: "calendar") }
                    .tag(Tab.calendar)
                    
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
            }
        }
        .fullScreenCover(isPresented: $purchaseManager.subscriptionViewPresent) {
            SubscriptionView()
        }
        .refreshable {
            do {
                self.appData = try AppData.load()
            } catch {
                self.isError = true
                print(error.localizedDescription)
            }
        }
        .preferredColorScheme(.light)
        .onChange(of: scenePhase) {
            if scenePhase == .background || scenePhase == .inactive {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
        .task {
            loadAppData()
        }
    }
    func loadAppData() {
        if isFirst {
            do {
                self.appData = try AppData.tutorial()
                try self.appData.save()
                self.isError = false
            } catch {
                isError = true
                print(error.localizedDescription)
            }
            self.isFirst = false
        } else {
            do {
                self.appData = try AppData.load()
                self.isError = false
            } catch {
                print(error.localizedDescription)
                self.isError = true
            }
        }
    }
}

#Preview {
    ContentView()
}
