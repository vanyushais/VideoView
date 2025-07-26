//
//  ContentView.swift
//  VideoCamera
//
//  Created by Ivan Istomin on 26.07.2025.
//

import SwiftUI

struct ContentView: View {
    let urls: [URL] = [
        URL(string: "rtsp://178.141.83.23:60555/ajUc3JQx_s/")!,
        URL(string: "rtsp://178.141.83.23:60555/Rrxy9uhI_s/")!,
        URL(string: "rtsp://178.141.83.23:60555/KZNvfCCS_s/")!,
        URL(string: "rtsp://admin:12345@217.9.151.201:555/wwxFTFxX_s/")!
    ]

    @State private var currentIndex = 0
    @State private var isLoading = true
    @State private var showError = false
    @State private var streamID = UUID()

    var body: some View {
        ZStack {
            RTSPPlayerView(url: urls[currentIndex], onPlaybackStarted: {
                isLoading = false
                showError = false
            })
            .id(streamID)

            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            }

            if showError {
                Text("Не удалось загрузить видео за 5 секунд")
                    .foregroundColor(.red)
                    .padding()
                    .background(Color.white.opacity(0.8))
                    .cornerRadius(10)
            }

            VStack {
                Spacer()
                HStack {
                    Button("←") {
                        switchStream(to: currentIndex - 1)
                    }
                    .padding()
                    .disabled(currentIndex == 0)

                    Button("→") {
                        switchStream(to: currentIndex + 1)
                    }
                    .padding()
                    .disabled(currentIndex == urls.count - 1)
                }
            }
        }
        .onAppear {
            startTimeoutTimer()
        }
    }

    func switchStream(to index: Int) {
        guard urls.indices.contains(index) else { return }
        currentIndex = index
        isLoading = true
        showError = false
        streamID = UUID()
        startTimeoutTimer()
    }

    func startTimeoutTimer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if isLoading {
                showError = true
            }
        }
    }
}
