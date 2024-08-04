//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 6/28/24.
//

import SwiftUI
import StoreKit

struct SettingsView: View {
    @Binding var appData: AppData
    @ObservedObject private var purchaseManager = PurchaseManager.shared
    @AppStorage("showAd") private var showAd: Bool = true
    var body: some View {
        List {
#if DEBUG
            Section("Data") {
                Button("Export Data") {
                    let encoder = JSONEncoder()
                    guard let data = try? encoder.encode(appData) else {
                        return
                    }
                    guard let string = String(data: data, encoding: .utf8) else {
                        return
                    }
                    print(string)
                }

                Button("Load Data") {
                    
                }
                Toggle(isOn: $purchaseManager.isDebugMode) {
                    Text("debugMode")
                }
                Toggle(isOn: $showAd) {
                    Text("Advertisement")
                }
            }
#endif
            Section("Subscribe") {
                Button("Unlock all features") {
                    PurchaseManager.shared.subscriptionViewPresent.toggle()
                }
            }
            Section("Tutorial") {
                Button("Set Tutorial") {
                    do {
                        try appData.loadTutorial()
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
            
            Section("About") {
                Button("Created by Wonyoung Jang") {
                    let appURL = URL(string: "instagram://user?username=j_w_y_j")!
                    let application = UIApplication.shared

                    if application.canOpenURL(appURL) {
                        application.open(appURL)
                    } else {
                        // if Instagram app is not installed, open URL inside Safari
                        let webURL = URL(string: "https://instagram.com/j_w_y_j")!
                        application.open(webURL)
                    }
                }
                
                Button("Designed by Anfaloumrani") {
                    let appURL = URL(string: "instagram://user?username=anfaloumrani")!
                    let application = UIApplication.shared

                    if application.canOpenURL(appURL) {
                        application.open(appURL)
                    } else {
                        // if Instagram app is not installed, open URL inside Safari
                        let webURL = URL(string: "https://www.behance.net/gallery/194635105/Everglow-chocolate-visual-identity?fbclid=PAZXh0bgNhZW0CMTEAAaYdmxZJMDHYKRC0EQ3U1rZs3XIBmGKIKVypafrTwNpJTwc3nSsglb6JQ7A_aem_iKbywhKyeVWn4ubt27TsKA")!
                        application.open(webURL)
                    }
                }

                
                Button("Privacy Policy") {
                    guard let url = URL(string: "https://sites.google.com/view/project-runner-pp/") else {
                        return
                    }
                    guard UIApplication.shared.canOpenURL(url) else {
                        return
                    }
                    UIApplication.shared.open(url)
                }
                
                Button("View App Permissions") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }
                
                Button("Rate") {
                    guard let currentScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
                        return
                    }
                    SKStoreReviewController.requestReview(in: currentScene)
                }
            }
            
            Section("Version") {
                Text(getVersion())
            }
        }
        .navigationTitle("Settings")
    }
    
    func getVersion() -> String {
        let dictionary = Bundle.main.infoDictionary
        let version = dictionary?["CFBundleShortVersionString"] as? String
        let build = dictionary?["CFBundleVersion"] as? String
        return "\(version ?? "Unknown") (\(build ?? "Unknown"))"
    }
}

#Preview {
    ContentView()
}
