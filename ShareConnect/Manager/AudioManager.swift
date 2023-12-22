//
//  AudioManager.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/22.
//

import Foundation
import AVFAudio
protocol AudioManagerDelegate: AnyObject {
    func audioManagerDidFinishPlaying()
    func audioManagerDecodeErrorDidOccur(error: Error?)
}
class AudioManager: NSObject, AVAudioPlayerDelegate {
    static let shared = AudioManager()
    weak var delegate: AudioManagerDelegate?
    private var audioPlayer: AVAudioPlayer?
    
    func playAudio(from url: URL) {
        stopAudio()
        if FileManager.default.fileExists(atPath: url.path) {
            setupAudioPlayer(with: url)
        } else {
            downloadFileFromURL(url: url)
        }
    }
    func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
   private func downloadFileFromURL(url: URL) {
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationURL = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            setupAudioPlayer(with: destinationURL)
        } else {
            URLSession.shared.downloadTask(with: url) { [weak self] (tempURL, _, error) in
                guard let self = self, let tempURL = tempURL, error == nil else {
                    print("Error downloading file: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                do {
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                    self.setupAudioPlayer(with: destinationURL)
                } catch {
                    print("Error moving file: \(error.localizedDescription)")
                }
            }.resume()
        }
    }
   private func setupAudioPlayer(with fileURL: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: fileURL)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            delegate?.audioManagerDecodeErrorDidOccur(error: error)
        }
    }
    func togglePlayPause() {
           if let audioPlayer = audioPlayer {
               if audioPlayer.isPlaying {
                   audioPlayer.pause()
               } else {
                   audioPlayer.play()
               }
           } else {
               print("Audio player is nil. Check the file format and URL.")
           }
       }
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        delegate?.audioManagerDidFinishPlaying()
    }
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        delegate?.audioManagerDecodeErrorDidOccur(error: error)
    }
}
