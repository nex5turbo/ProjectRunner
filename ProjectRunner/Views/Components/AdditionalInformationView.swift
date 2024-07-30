//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/5/24.
//

import SwiftUI

struct AdditionalInformationView: View {
    let schedule: Schedulable
    @State private var iconSize: CGFloat = 0
    let currentDate = Date.now
    var body: some View {
        HStack(spacing: 4) {
            let hasAppointment = !schedule.appointments.isEmpty
            Image("appointment")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(hasAppointment ? .yellow : .gray)
            
            Text("\(schedule.appointments.count)")
                .font(.caption2)
                .overlay {
                    GeometryReader { proxy in
                        Color.clear
                            .task {
                                self.iconSize = proxy.size.height
                            }
                            .onChange(of: proxy.size, perform: { _ in
                                self.iconSize = proxy.size.height
                            })
                    }
                }
            
            Color.clear.frame(width: 1, height: 1)
            let hasMoment = !schedule.moments.isEmpty
            Image("moment")
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: iconSize, height: iconSize)
                .foregroundStyle(hasMoment ? .blue : .gray)
            
            Text("\(schedule.moments.count)")
                .font(.caption2)
            Spacer()
            
            if schedule.hasDeadline && (schedule.status != .done && schedule.status != .canceled) {
                Text("\(Calendar.current.timeLeft(from: currentDate, to: schedule.dueDate))")
                    .font(.caption2)
            }
        }
        .foregroundStyle(.gray)
        .font(.footnote)
    }
}

#Preview {
    ContentView()
}
