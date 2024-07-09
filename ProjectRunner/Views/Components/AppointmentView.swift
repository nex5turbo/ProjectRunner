//
//  SwiftUIView.swift
//
//
//  Created by 워뇨옹 on 7/6/24.
//

import SwiftUI

struct AppointmentView: View {
    @State var schedule: Schedulable
    @Binding var appData: AppData
    init(schedule: Schedulable, appData: Binding<AppData>) {
        self._schedule = State(initialValue: schedule)
        self._appData = appData
    }
    @State var isAddPresented: Bool = false
    @State private var newAppointment: TAppointment = TAppointment()
    @State private var permissionAlert: Bool = false
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Events")
                    .font(.headline)
                Text("\(schedule.appointments.count)")
                    .font(.caption)
                    .foregroundStyle(.gray)
                Spacer()
                Button {
                    self.newAppointment = TAppointment()
                    self.isAddPresented = !self.isAddPresented
                } label: {
                    Text("+ New Event")
                }
            }

            ForEach(schedule.appointments, id: \.self) { appointment in
                HStack {
                    VStack(alignment: .leading) {
                        Text(appointment.comment)
                            .overlay {
                                if appointment.isDone {
                                    Color.black.frame(height: 1)
                                        .frame(maxWidth: .infinity)
                                }
                            }
                        Text(appointment.notifyAt.toString(true))
                            .font(.footnote)
                            .foregroundStyle(.gray)
                    }
                    Spacer(minLength: 0)
                    VStack {
                        HStack {
                            Button {
                                guard let index = schedule.appointments.firstIndex(of: appointment) else {
                                    return
                                }
                                var modifiedAppointment = appointment
                                modifiedAppointment.hasNotification = !modifiedAppointment.hasNotification
                                do {
                                    try appData.addAppointment(schedule: schedule, appintment: modifiedAppointment)
                                    schedule.appointments[index] = modifiedAppointment
                                } catch {
                                    print(error.localizedDescription)
                                }
                            } label: {
                                Image(systemName: appointment.hasNotification ? "bell.fill" : "bell.slash")
                                    .font(.footnote)
                                    .foregroundStyle(appointment.hasNotification ? .yellow : .gray)
                            }
                            Button {
                                do {
                                    try appData.removeAppointment(schedule: schedule, appointment: appointment)
                                    self.schedule.appointments.removeAll(where: { $0.id == appointment.id })
                                } catch {
                                    print(error.localizedDescription)
                                }
                                
                            } label: {
                                Image(systemName: "xmark")
                                    .foregroundStyle(.gray)
                                    .font(.footnote)
                            }

                        }

                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.white)
                .cornerRadius(8)
                .shadow(radius: 1, x: 1, y: 1)
                .onTapGesture {
                    self.newAppointment = appointment
                    self.isAddPresented = true
                }
            }
        }
        .padding()
        .sheet(isPresented: $isAddPresented, content: {
            NavigationStack {
                List {
                    TextField("", text: $newAppointment.comment, prompt: Text("Event description..."))
                        .font(.headline)
                    DatePicker(selection: $newAppointment.notifyAt) {
                        Text("Event at")
                    }
                    Toggle(isOn: $newAppointment.hasNotification) {
                        Text("Notification")
                    }
                    if newAppointment.hasNotification {
                        Toggle(isOn: $newAppointment.shouldRepeat) {
                            Text("Repeat")
                        }
                    }
                }
                .navigationTitle("New Event")
                .toolbar {
                    ToolbarItem {
                        Button("Save") {
                            if newAppointment.hasNotification {
                                NotificationManager.instance.requestAuthorization { granted in
                                    if granted {
                                        do {
                                            try appData.addAppointment(schedule: schedule, appintment: newAppointment)
                                            if let index = schedule.appointments.firstIndex(where: { $0.id == newAppointment.id }) {
                                                schedule.appointments[index] = newAppointment
                                            } else {
                                                schedule.appointments.append(newAppointment)
                                            }
                                            self.isAddPresented = false
                                        } catch {
                                            print(error.localizedDescription)
                                        }
                                    } else {
                                        self.permissionAlert = true
                                    }
                                }
                            } else {
                                do {
                                    try appData.addAppointment(schedule: schedule, appintment: newAppointment)
                                    if let index = schedule.appointments.firstIndex(where: { $0.id == newAppointment.id }) {
                                        schedule.appointments[index] = newAppointment
                                    } else {
                                        schedule.appointments.append(newAppointment)
                                    }
                                    self.isAddPresented = false
                                } catch {
                                    print(error.localizedDescription)
                                }
                            }
                            
                            do {
                                try appData.addAppointment(schedule: schedule, appintment: newAppointment)
                                if let index = schedule.appointments.firstIndex(where: { $0.id == newAppointment.id }) {
                                    schedule.appointments[index] = newAppointment
                                } else {
                                    schedule.appointments.append(newAppointment)
                                }
                                self.isAddPresented = false
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                        .alert("Allow notification permission to set notification.", isPresented: $permissionAlert) {
                            Button("Settings") {
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                            }
                            Button("Cancel", role: .cancel) {
                                
                            }
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        })
    }
}

#Preview {
    ContentView()
}
