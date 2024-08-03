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
            Image(systemName: hasAppointment ? "clock.badge.exclamationmark.fill" : "clock")
                .font(.caption2)
                .foregroundStyle(hasAppointment ? .yellow : .gray)
            
            Text("\(schedule.appointments.count)")
                .font(.caption2)
            
            Color.clear.frame(width: 1, height: 1)
            let hasMoment = !schedule.moments.isEmpty
            Image(systemName: hasMoment ? "ellipsis.bubble.fill" : "ellipsis.bubble")
                .font(.caption2)
                .foregroundStyle(hasMoment ? .blue : .gray)
            
            Text("\(schedule.moments.count)")
                .font(.caption2)
            Color.clear.frame(width: 1, height: 1)
            let hasRef = !schedule.files.isEmpty
            Image(systemName: hasRef ? "paperclip" : "paperclip")
                .font(.caption2)
                .foregroundStyle(hasRef ? .green : .gray)
            
            Text("\(schedule.files.count)")
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
