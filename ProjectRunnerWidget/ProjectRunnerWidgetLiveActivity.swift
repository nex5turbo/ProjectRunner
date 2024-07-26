//
//  ProjectRunnerWidgetLiveActivity.swift
//  ProjectRunnerWidget
//
//  Created by 워뇨옹 on 7/16/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct ProjectRunnerWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct ProjectRunnerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ProjectRunnerWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension ProjectRunnerWidgetAttributes {
    fileprivate static var preview: ProjectRunnerWidgetAttributes {
        ProjectRunnerWidgetAttributes(name: "World")
    }
}

extension ProjectRunnerWidgetAttributes.ContentState {
    fileprivate static var smiley: ProjectRunnerWidgetAttributes.ContentState {
        ProjectRunnerWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: ProjectRunnerWidgetAttributes.ContentState {
         ProjectRunnerWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: ProjectRunnerWidgetAttributes.preview) {
   ProjectRunnerWidgetLiveActivity()
} contentStates: {
    ProjectRunnerWidgetAttributes.ContentState.smiley
    ProjectRunnerWidgetAttributes.ContentState.starEyes
}
