//
//  OnBoardingSheet.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 8/8/24.
//

import SwiftUI

struct OnBoardingSheet: View {
    @State private var currentPage: Int = 0
    @State private var notificationAlertPresented: Bool = false
    
    private let titleFont: Font = .title
    private let contentFont: Font = .title3
    var body: some View {
        TabView(selection: $currentPage) {
            firstPage()
            
            secondPage()
            
            thirdPage()
            
            forthPage()
            
            fifthPage()
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
    
    @ViewBuilder func firstPage() -> some View {
        VStack(alignment: .leading) {
            Text("Project Runner helps you to achieve your goal")
                .font(titleFont)
                .padding(.vertical)
            Text("Set your projects")
                .font(contentFont)
            LottieView(jsonName: "Project")
            Spacer()
            nextButton {
                withAnimation {
                    currentPage = 1
                }
            }
        }
        .padding()
        .tag(0)
    }
    
    @ViewBuilder func secondPage() -> some View {
        VStack(alignment: .leading) {
            Text("Don't keep your tasks only in your mind")
                .font(titleFont)
                .padding(.vertical)
            Text("Set your tasks")
                .font(contentFont)
            LottieView(jsonName: "Task")
            Spacer()
            nextButton {
                withAnimation {
                    currentPage = 2
                }
            }
        }
        .padding()
        .tag(1)
    }
    
    @ViewBuilder func thirdPage() -> some View {
        VStack(alignment: .leading) {
            Text("Don't miss your feelings and innovative ideas")
                .font(titleFont)
                .padding(.vertical)
            Text("Write down diaries")
                .font(contentFont)
            LottieView(jsonName: "Diary")
            Spacer()
            nextButton {
                withAnimation {
                    currentPage = 3
                }
            }
        }
        .padding()
        .tag(2)
    }
    
    @ViewBuilder func forthPage() -> some View {
        VStack(alignment: .leading) {
            Text("Don't miss your important schedules")
                .font(titleFont)
                .padding(.vertical)
            Text("Set your events")
                .font(contentFont)
            LottieView(jsonName: "Notification")
            Spacer()
            nextButton("Allow Notifications") {
                NotificationManager.instance.requestAuthorization { granted in
                    if !granted {
                        notificationAlertPresented.toggle()
                    } else {
                        withAnimation {
                            currentPage = 4
                        }
                    }
                }
            }
            .alert("Please allow permission to get notifications", isPresented: $notificationAlertPresented) {
                Button("Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                    withAnimation {
                        currentPage = 4
                    }
                }
                Button("Cancel", role: .cancel) {
                    withAnimation {
                        currentPage = 4
                    }
                }
            }
        }
        .padding()
        .tag(3)
    }
    
    @ViewBuilder func fifthPage() -> some View {
        SubscriptionView()
            .tag(4)
    }
    
    @ViewBuilder func nextButton(_ title: String = "Next Step", _ action: @escaping () -> Void) -> some View {
        RoundedButton(title) {
            action()
        }
        .bgColor(.blue.opacity(0.2))
        .shadow(color: .white, radius: 3)
    }
}

#Preview {
    OnBoardingSheet()
}
