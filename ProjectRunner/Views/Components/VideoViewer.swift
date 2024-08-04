//
//  VideoViewer.swift
//  ProjectRunner
//
//  Created by 워뇨옹 on 8/4/24.
//

import SwiftUI
import AVFoundation
import _AVKit_SwiftUI

// Custom UIViewRepresentable to integrate AVPlayer
struct VideoPlayerView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        playerViewController.showsPlaybackControls = true // Show playback controls
        return playerViewController
    }
    
    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        if uiViewController.player?.currentItem == nil {
            uiViewController.player = AVPlayer(url: url)
        }
        uiViewController.player?.play() // Start playing the video
    }
}


struct VideoViewer: View {
    private let url: URL
    
    init(url: URL) {
        self.url = url
    }
    
    var body: some View {
        VideoPlayerView(url: url)
            .edgesIgnoringSafeArea(.all)
    }
}

#Preview {
    ContentView()
}
