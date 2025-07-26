//
//  RTSPPlayerView.swift
//  VideoCamera
//
//  Created by Ivan Istomin on 26.07.2025.
//

import SwiftUI
import MobileVLCKit

struct RTSPPlayerView: UIViewControllerRepresentable {
    let url: URL
    let onPlaybackStarted: () -> Void

    func makeUIViewController(context: Context) -> RTSPPlayerViewController {
        let vc = RTSPPlayerViewController()
        vc.url = url
        vc.onPlaybackStarted = onPlaybackStarted
        return vc
    }

    func updateUIViewController(_ uiViewController: RTSPPlayerViewController, context: Context) {
        uiViewController.url = url
        uiViewController.onPlaybackStarted = onPlaybackStarted
        uiViewController.reloadStream()
    }
}

class RTSPPlayerViewController: UIViewController, @preconcurrency VLCMediaPlayerDelegate {
    var mediaPlayer: VLCMediaPlayer?
    var videoView = UIView()
    var url: URL?
    var onPlaybackStarted: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        videoView.frame = view.bounds
        videoView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(videoView)
    }

    func reloadStream() {
        mediaPlayer?.stop()

        guard let url = url else { return }

        mediaPlayer = VLCMediaPlayer()
        mediaPlayer?.drawable = videoView
        mediaPlayer?.media = VLCMedia(url: url)
        mediaPlayer?.delegate = self
        mediaPlayer?.media?.addOptions([
            "network-caching": 300, // буфер 300 мс вместо 1000
            "rtsp-tcp": true         // использовать TCP для RTSP (устойчивее)
        ])
        mediaPlayer?.play()
    }

    // MARK: - VLCMediaPlayerDelegate
    func mediaPlayerStateChanged(_ aNotification: Notification) {
        guard let state = mediaPlayer?.state else { return }

        if state == .playing {
            DispatchQueue.main.async {
                self.onPlaybackStarted?()
            }
        }

        if state == .error {
            DispatchQueue.main.async {
                print("Ошибка воспроизведения")
            }
        }
    }
}
