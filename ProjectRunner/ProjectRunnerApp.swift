//
//  ProjectRunnerApp.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/9/24.
//

import SwiftUI
import GoogleMobileAds
import SwiftyStoreKit

@main
struct ProjectRunnerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("showAd") private var showAd: Bool = true
    private var openAd: OpenAd = OpenAd()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    PurchaseManager.shared.verifySubscription { result in
                        switch result {
                        case .purchased(let expiryDate, let items):
                            PurchaseManager.shared.setUserPremium(as: true)
                        case .expired(let expiryDate, let items):
                            PurchaseManager.shared.setUserPremium(as: false)
                        case .notPurchased:
                            PurchaseManager.shared.setUserPremium(as: false)
                        }
                    }
                }
                .onChange(of: scenePhase) {
                    if scenePhase == .active {
#if !DEBUG
                        if !PurchaseManager.shared.isPremiumUser {
                            openAd.requestAppOpenAd()
                        }
#else
                        if showAd {
                            openAd.requestAppOpenAd()
                        }
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
        GADMobileAds.sharedInstance().start()
        SwiftyStoreKit.completeTransactions(atomically: false) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                case .failed, .purchasing, .deferred:
                    break
                @unknown default:
                    break
                }
            }
        }
        return true
    }
}
