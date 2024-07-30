////
////  SwiftUIView.swift
////
////
////  Created by 워뇨옹 on 6/27/24.
////
//
//import SwiftUI
//
//struct AnimatedTimeline: View {
//    private let timer = Timer.publish(every: 1, on: RunLoop.main, in: RunLoop.Mode.common).autoconnect()
//    @State private var currentDate: Date = Date.now
//    @State var schedule: Schedulable
//    @Binding var appData: AppData
//    init(schedule: Schedulable, appData: Binding<AppData>) {
//        self._schedule = State(initialValue: schedule)
//        self._appData = appData
//    }
//    private var shouldShowTimeline: Bool = true
//    private let barHeight: CGFloat = 8
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            if shouldShowTimeline {
//                HStack(spacing: 0) {
//                    let canceled = currentDate.timeIntervalSince1970 - (schedule.canceledAt?.timeIntervalSince1970 ?? 0.0)
//                    let done = currentDate.timeIntervalSince1970 - (schedule.doneAt?.timeIntervalSince1970 ?? 0.0)
//                    let current = currentDate.timeIntervalSince1970 - schedule.startDate.timeIntervalSince1970
//                    let adjusted = schedule.dueDate.timeIntervalSince1970 - schedule.startDate.timeIntervalSince1970
//                    let percent: Double = current / adjusted
//                    let donePercent: Double = done / adjusted
//                    let canceledPercent: Double = canceled / adjusted
//                    
//                    GeometryReader { proxy in
//                        let offset = {
//                            return switch schedule.status {
//                            case .preparing:
//                                max(0.0, min(proxy.size.width, proxy.size.width * CGFloat(percent)))
//                            case .inProgress:
//                                max(0.0, min(proxy.size.width, proxy.size.width * CGFloat(percent)))
//                            case .done:
//                                max(0.0, min(proxy.size.width, proxy.size.width * CGFloat(donePercent)))
//                            case .todo:
//                                max(0.0, min(proxy.size.width, proxy.size.width * CGFloat(canceledPercent)))
//                            case .canceled:
//                                max(0.0, min(proxy.size.width, proxy.size.width * CGFloat(percent)))
//                            }
//                        }()
//                        RoundedRectangle(cornerRadius: 8)
//                            .fill(Color.gray)
//                            .frame(maxWidth: CGFloat.infinity)
//                            .frame(height: barHeight)
//                            .overlay {
//                                HStack {
//                                    RoundedRectangle(cornerRadius: 8)
//                                        .fill(.blue)
//                                        .frame(width: offset,height: barHeight)
//                                    Spacer(minLength: 0)
//                                }
//                            }
//                            .clipped()
//                    }
//                }
//                .frame(height: barHeight)
//            }
//        }
//        .onReceive(timer) { newValue in
//            withAnimation {
//                self.currentDate = Date.now
//            }
//        }
//    }
//    
//    public func showTimeline(_ value: Bool) -> Self {
//        var view = self
//        view.shouldShowTimeline = value
//        return view
//    }
//}
//
//#Preview {
//    ContentView()
//}
