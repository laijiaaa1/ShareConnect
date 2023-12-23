//
//  ChatVC_Audio.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/17.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import Kingfisher
import MapKit
import CoreLocation
import AVFoundation
import AVKit
import Firebase
import FirebaseDatabase

extension ChatViewController {
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    func startRecording() {
        let audioFilename = getDocumentsDirectory().appendingPathComponent("recording.wav")
        let settings = [
            AVFormatIDKey: Int(kAudioFormatLinearPCM),
            AVSampleRateKey: 12000,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            isRecording = true
            updateUIForRecording(true)
        } catch {
            print("錄音失敗")
        }
    }
    func stopRecording() {
        audioRecorder.stop()
        audioRecorder = nil
        isRecording = false
        updateUIForRecording(false)
        audioFileURL = audioFileURL ?? getDocumentsDirectory().appendingPathComponent("recording.wav")
    }
    func updateUIForRecording(_ isRecording: Bool) {
        if isRecording {
            voiceButton.setImage(UIImage(systemName: "mic.fill"), for: .normal)
            voiceButton.tintColor = .red
        } else {
            voiceButton.setImage(UIImage(systemName: "mic"), for: .normal)
            voiceButton.tintColor = .white
        }
    }
    func uploadAudioToFirebase() {
        guard let audioFileURL = audioFileURL else {
            print("Error: audioFileURL is nil.")
            return
        }
        guard let audioData = try? Data(contentsOf: audioFileURL) else {
            print("Error creating audio data.")
            return
        }
        let audioStorageRef = Storage.storage().reference().child("audio")
        let audioRef = audioStorageRef.child(UUID().uuidString + ".wav")
        audioRef.putData(audioData, metadata: nil) { [weak self] (metadata, error) in
            guard let self = self else {
                print("Self is nil.")
                return
            }
            if let error = error {
                print("Upload failed: \(error.localizedDescription)")
                return
            }
            audioRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("Unable to get download URL: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                self.saveAudioMessageToDatabase(downloadURL: downloadURL.absoluteString)
            }
        }
    }
    func saveAudioMessageToDatabase(downloadURL: String) {
        guard let chatRoomDocument = chatRoomDocument else {
            print("Chat room document is nil.")
            return
        }
        let messagesCollection = chatRoomDocument.collection("messages")
        let audioMessage = [
            "text": downloadURL,
            "audioURL": downloadURL,
            "isMe": true,
            "timestamp": FieldValue.serverTimestamp(),
            "name": currentUser?.name ?? "",
            "profileImageUrl": currentUser?.profileImageUrl ?? "",
            "buyer": currentUser?.uid ?? "",
            "seller": buyerID ?? "",
            "chatRoomID": chatRoomID ?? "",
            "imageURL": nil ?? "",
        ] as [String : Any]
        messagesCollection.addDocument(data: audioMessage) { [weak self] (error) in
            if let error = error {
                print("Error sending audio message: \(error.localizedDescription)")
                return
            }
            self?.tableView.reloadData()
        }
    }
}
