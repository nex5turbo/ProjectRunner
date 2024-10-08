//
//  FilterSheet.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 7/10/24.
//

import SwiftUI

/**
 color
 status
 priority
 label
 due date
 */

enum FilterParentType {
    case all
    case parent
    case sub
}

struct FilterOptions {
    var searchText: String = ""
    var colors: Set<MarkColor> = []
    var status: Set<Status> = []
    var priorities: Set<Priority> = []
    var labels: Set<TLabel> = []
    var shouldPresentNoDeadline: Bool = false
    var isDateOn: Bool {
        fromDate != nil || toDate != nil
    }
    var fromDate: Date.SelectableDates? = nil
    var toDate: Date.SelectableDates? = nil
    var filterParentType: FilterParentType = .all
    var hasSubTask: Bool? = nil
    var isActivated: Bool {
        !colors.isEmpty ||
        !status.isEmpty ||
        !priorities.isEmpty ||
        !labels.isEmpty ||
        shouldPresentNoDeadline ||
        isDateOn ||
        hasSubTask != nil ||
        filterParentType != .all
    }
    
    func filter(tasks: [TTask], appData: AppData) -> [TTask] {
        // TODO: IMPLEMENT
        return []
    }
    
    func filter(project: [TProject], appData: AppData) -> [TProject] {
        // TODO: IMPLEMENT
        return []
    }
}

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @State private var filterOptions: FilterOptions
    @Binding private var appData: AppData
    let onDismiss: (FilterOptions) -> Void
    private let headerFont: Font = .title3.weight(.semibold)
    init(
        filterOptions: FilterOptions,
        appData: Binding<AppData>,
        _ onDismiss: @escaping (FilterOptions) -> Void
    ) {
        self._filterOptions = State(initialValue: filterOptions)
        self._appData = appData
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading) {
                        Text("Mark colors")
                            .font(headerFont)
                            .padding(.horizontal)
                        ScrollView(.horizontal) {
                            HStack(spacing: 12) {
                                ForEach(MarkColor.allCases, id: \.self) { markColor in
                                    Button {
                                        if self.filterOptions.colors.contains(markColor) {
                                            self.filterOptions.colors.remove(markColor)
                                        } else {
                                            self.filterOptions.colors.insert(markColor)
                                        }
                                    } label: {
                                        Circle().fill(markColor.color)
                                            .frame(width: 33)
                                            .overlay {
                                                if self.filterOptions.colors.contains(markColor) {
                                                    Circle().stroke(.black, lineWidth: 4)
                                                } else {
                                                    Circle().stroke(.black, lineWidth: 0.5)
                                                }
                                            }
                                    }
                                }
                            }
                            .padding(4)
                            .padding(.horizontal)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("Status")
                            .font(headerFont)
                            .padding(.horizontal)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(Status.allCases, id: \.self) { status in
                                    Button {
                                        if self.filterOptions.status.contains(status) {
                                            self.filterOptions.status.remove(status)
                                        } else {
                                            self.filterOptions.status.insert(status)
                                        }
                                    } label: {
                                        TopButtonChip(
                                            title: status.title,
                                            imageName: status.systemName,
                                            isSystem: true) {
                                                
                                            }
                                            .isSelected(self.filterOptions.status.contains(status))
                                            .setImageColor(status.imageColor)
                                            .imageBold()
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("Prioirity")
                            .font(headerFont)
                            .padding(.horizontal)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(Priority.allCases, id: \.self) { priority in
                                    Button {
                                        if self.filterOptions.priorities.contains(priority) {
                                            self.filterOptions.priorities.remove(priority)
                                        } else {
                                            self.filterOptions.priorities.insert(priority)
                                        }
                                    } label: {
                                        TopButtonChip(
                                            title: priority.title,
                                            imageName: "",
                                            isSystem: true) {
                                                PriorityIcon(priority: priority)
                                            }
                                            .isSelected(self.filterOptions.priorities.contains(priority))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("Label")
                            .font(headerFont)
                            .padding(.horizontal)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(appData.labels, id: \.self) { label in
                                    Button {
                                        if self.filterOptions.labels.contains(label) {
                                            self.filterOptions.labels.remove(label)
                                        } else {
                                            self.filterOptions.labels.insert(label)
                                        }
                                    } label: {
                                        TopButtonChip(
                                            title: label.content,
                                            imageName: "",
                                            isSystem: true) {
                                            }
                                            .isSelected(self.filterOptions.labels.contains(label))
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    VStack(alignment: .leading) {
                        Text("Sub tasks")
                            .font(headerFont)
                            .padding(.horizontal)
                        ScrollView(.horizontal) {
                            HStack {
                                Button {
                                    self.filterOptions.hasSubTask = nil
                                } label: {
                                    TopButtonChip(
                                        title: "All tasks",
                                        imageName: "",
                                        isSystem: true) {
                                        }
                                        .isSelected(self.filterOptions.hasSubTask == nil)
                                }
                                Button {
                                    self.filterOptions.hasSubTask = true
                                } label: {
                                    TopButtonChip(
                                        title: "Sub task",
                                        imageName: "",
                                        isSystem: true) {
                                        }
                                        .isSelected(self.filterOptions.hasSubTask == true)
                                }
                                Button {
                                    self.filterOptions.hasSubTask = false
                                } label: {
                                    TopButtonChip(
                                        title: "No Sub task",
                                        imageName: "",
                                        isSystem: true) {
                                        }
                                        .isSelected(self.filterOptions.hasSubTask == false)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Due date")
                            .font(headerFont)
                            .padding(.horizontal)
                        ScrollView(.horizontal) {
                            HStack {
                                Button {
                                    self.filterOptions.toDate = nil
                                } label: {
                                    TopButtonChip(
                                        title: "Without",
                                        imageName: "",
                                        isSystem: true) {
                                        }
                                        .isSelected(self.filterOptions.toDate == nil)
                                }
                                ForEach(Date.SelectableDates.allCases, id: \.self) { date in
                                    Button {
                                        self.filterOptions.toDate = date
                                    } label: {
                                        TopButtonChip(
                                            title: date.title,
                                            imageName: "",
                                            isSystem: true) {
                                            }
                                            .isSelected(self.filterOptions.toDate == date)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
//                    VStack(alignment: .leading) {
//                        Toggle(isOn: $filterOptions.isDateOn, label: {
//                            Text("Date filter")
//                                .font(headerFont)
//                        })
//                        if filterOptions.isDateOn {
//                            Button {
//                                
//                            } label: {
//                                Text("From")
//                            }
//
//                        }
//                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        onDismiss(.init())
                        dismiss()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .bold()
                    }
                    .disabled(!filterOptions.isActivated)
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        onDismiss(filterOptions)
                        dismiss()
                    } label: {
                        Text("Apply")
                            .bold()
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .scrollIndicators(.never)
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    FilterSheet(filterOptions: FilterOptions(), appData: .constant(.init())) { options in
    }
}
