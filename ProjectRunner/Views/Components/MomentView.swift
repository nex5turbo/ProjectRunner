//
//  SwiftUIView.swift
//  
//
//  Created by 워뇨옹 on 7/5/24.
//

import SwiftUI

struct MomentView: View {
    @Binding var appData: AppData
    @State var schedule: Schedulable
    init(appData: Binding<AppData>, schedule: Schedulable) {
        self._appData = appData
        self._schedule = State(initialValue: schedule)
    }
    @State private var newMoment: TMoment = TMoment()
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .center) {
                Text("Moments")
                    .font(.headline)
                Text("\(schedule.moments.count)")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
            HStack {
                TextField("content", text: $newMoment.comment, prompt: Text("Any idea or achivement at this time."))
                    .textFieldStyle(.roundedBorder)
                Button {
                    do {
                        newMoment.createdAt = Date.now
                        try appData.addMoment(schedule: schedule, moment: newMoment)
                        self.schedule.moments.append(newMoment)
                        self.newMoment = TMoment()
                    } catch {
                        print(error.localizedDescription)
                    }
                } label: {
                    Text("Save")
                }
                .disabled(newMoment.comment == "")
            }
            .padding(.bottom)
            
            ForEach(schedule.moments, id: \.self) { moment in
                HStack {
                    VStack(alignment: .leading) {
                        Text(moment.comment)
                            .strikethrough(moment.isDone)
                            .foregroundStyle(moment.isDone ? .gray : .black)
                        HStack {
                            Text(moment.createdAt.toString(true))
                                .foregroundStyle(.gray)
                            if moment.isDone {
                                Text("DONE")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .font(.footnote.weight(.semibold))
                    }
                    Spacer(minLength: 0)
                    VStack {
                        Button {
                            do {
                                try appData.removeMoment(schedule: schedule, moment: moment)
                                self.schedule.moments.removeAll(where: { $0.id == moment.id })
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.gray)
                                .font(.footnote)
                        }

                        Spacer()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.white)
                .cornerRadius(8)
                .shadow(radius: 1, x: 1, y: 1)
                .onTapGesture(count: 2) {
                    do {
                        guard let index = self.schedule.moments.firstIndex(of: moment) else {
                            return
                        }
                        var modifiedMoment = moment
                        modifiedMoment.isDone = !modifiedMoment.isDone
                        try appData.addMoment(schedule: schedule, moment: modifiedMoment)
                        self.schedule.moments[index] = modifiedMoment
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
