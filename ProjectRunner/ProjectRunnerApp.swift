//
//  ProjectRunnerApp.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/9/24.
//

import SwiftUI
import GoogleMobileAds

@main
struct ProjectRunnerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    private var openAd: OpenAd = OpenAd()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
                        #if !DEBUG
                        openAd.requestAppOpenAd()
                        #endif
                    }
                }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        #if DEBUG
        GADMobileAds.sharedInstance().requestConfiguration.testDeviceIdentifiers = [ "bb9291dbe456d9265819757dd73caae1" ]
        #endif
        GADMobileAds.sharedInstance().start()
        return true
    }
}
