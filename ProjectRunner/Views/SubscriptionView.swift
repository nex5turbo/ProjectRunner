//
//  SubscriptionView.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/26/24.
//

import SwiftUI

struct SubscriptionView: View {
    @ObservedObject private var purchaseManager = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss

    @State private var currentTab: Int = 0
    @State private var shouldShowNotice: Bool = false
    @State private var isPurchasing: Bool = false
    @State private var successAlert: Bool = false
    @State private var deferAlert: Bool = false
    @State private var errorAlert: Bool = false
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let subscriptionNotice: String =
"""
The subscription auto-renews at the end of each
period term at the same price, unless cancelled 24
hours in advance.

The subscription fee is charged to your iTunes account
at confirmation of purchase.

You may manage your subscription and turn off
auto-renewal by going to your settings.

No cancellation of the current subscription is allowed
during the active period.
"""
    var body: some View {
        ScrollView {
            ZStack {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(.black)
                    }
                    Spacer()
                    Button("RESOTRE") {
                        self.isPurchasing = true
                        purchaseManager.restorePremium { isSuccess in
                            self.isPurchasing = false
                        }
                    }
                    .foregroundStyle(.gray)
                }
                .padding()
            }
            
            Text("Unlock all features!")
                .font(.title)
                .bold()
            
            LottieView(jsonName: "subscription", loopMode: .loop)
                .frame(width: 300, height: 300)

            ScrollView(.horizontal) {
                HStack(spacing: 16) {
                    benefitSection(imageName: "square.stack.3d.up.fill", caption: "Unlimited\nProjects")
                    benefitSection(imageName: "list.bullet", caption: "Unlimited\nTasks")
                    benefitSection(imageName: "square.and.pencil", caption: "Unlimited\nDiaries")
                    benefitSection(imageName: "checkmark.icloud.fill", caption: "Save to\niCloud")
                    benefitSection(imageName: "nosign", caption: "Remove\nAll Ads")
                }
                .padding()
            }
            .scrollIndicators(.never)
            
            if let annualPrice = purchaseManager.getAnnualPrice() {
                Text("Start with a free one week trial, then auto-renews for \(annualPrice) / year.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.gray)
                    .padding()
                
                RoundedButton("Start 7-days free trial!") {
                    self.isPurchasing = true
                    purchaseManager.purchaseAnnualPremium { result in
                        switch result {
                        case .success(purchase: let purchase):
                            self.successAlert = true
                            purchaseManager.setUserPremium(as: true)
                        case .deferred(purchase: let purchase):
                            self.deferAlert = true
                            print("앱 재시작 혹은 restore")
                        case .error(error: let error):
                            self.errorAlert = true
                            print(error.localizedDescription)
                        }
                        self.isPurchasing = false
                    }
                }
                .bgColor(.blue.opacity(0.2))
                .shadow(color: .white, radius: 3)
                .alert("Thanks for purchasing!", isPresented: $successAlert) {
                    
                }
                .alert("Something wrong. Hit RESTORE button or reboot this app please!", isPresented: $deferAlert) {
                    
                }
                .alert("Transaction failed. Try again.", isPresented: $errorAlert) {
                    
                }
                
                Text("Payment will be made automatically after the trial ends.")
                    .font(.caption2)
                    .foregroundStyle(.gray)
            }
            HStack {
                Button {
                    
                    if let url = URL(string: "https://sites.google.com/view/project-runner-privacy/홈"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text("Privacy Policy")
                }
                Text("/")
                Button {
                    
                    if let url = URL(string: "https://sites.google.com/view/project-runner-terms/홈"), UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                } label: {
                    Text("Terms of use")
                }
            }
            .foregroundStyle(.gray)
            Image(systemName: shouldShowNotice ? "chevron.up" : "chevron.down")
                .font(.headline)
                .onTapGesture {
                    shouldShowNotice.toggle()
                }
                .padding()
            if shouldShowNotice {
                VStack(alignment: .center) {
                    Text(subscriptionNotice)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .overlay {
            if isPurchasing {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                VStack {
                    ProgressView()
                }
                .frame(width: 100, height: 100)
                .background(.white)
                .cornerRadius(10)
            }
        }
    }
    @ViewBuilder func benefitSection(imageName: String, caption: String) -> some View {
        let iconSize: CGFloat = 60
        VStack(alignment: .center) {
            Image(systemName: imageName)
                .font(.title)
                .frame(width: iconSize, height: iconSize)
            Text(caption)
                .font(.footnote)
                .multilineTextAlignment(.center)
        }
        .frame(width: iconSize)
    }
}

#Preview {
    SubscriptionView()
}
