//
//  VideoViewer.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 8/4/24.
//

import SwiftUI
import _AVKit_SwiftUI

struct VideoViewer: View {
    @State private var player: AVPlayer = AVPlayer()
    private let url: URL
    init(url: URL) {
        self.url = url
    }
    var body: some View {
        VideoPlayer(player: player)
            .task {
                self.player = AVPlayer(url: url)
                self.player.play()
            }
            .onDisappear {
                self.player.pause()
            }
    }
}

#Preview {
    ContentView()
}
