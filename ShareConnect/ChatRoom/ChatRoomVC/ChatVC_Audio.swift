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
            AVFormatIDKey: Int(kAudioFormatLinearPCM),  //指定要用於錄製的音訊格式或編解碼器， kAudioFormatLinearPCM （線性脈衝編碼調製）是一種以未壓縮的原始形式表示音訊的格式。這種格式以高品質而聞名，但與壓縮格式相比，會導致更大的檔大小。
            AVSampleRateKey: 12000,     //較低的採樣率會導致檔大小變小，但可能會降低錄製的品質。
            AVNumberOfChannelsKey: 1,   // 1 表示單聲道錄音。如果設置為 2 ，它將是立體聲錄音。單聲道使用單聲道，足以滿足大多數基本的錄音需求。
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue  //確定音訊編碼的品質。AVAudioQuality.high 是無損音訊編碼，它會導致更大的檔大小。
        ]
        do {
            audioRecorder = try AVAudioRecorder(url: audioFilename, settings: settings)     //初始化AVAudioRecorder 實例。
            audioRecorder.delegate = self
            audioRecorder.record()  //開始 AVAudioRecorder 根據給定的設置錄製音訊並將其保存到指定的檔URL。
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
            "imageURL": nil ?? ""
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
