//
//  ChatVC_Extension.swift
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

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages.count
    }
    @objc func imageTapped(_ gesture: UITapGestureRecognizer) {
        guard
            let cell = gesture.view?.superview?.superview as? ImageCell,
            let chatMessage = cell.chatMessage,
            let imageUrl = chatMessage.imageURL,
            let originalImage = cell.imageURLpost.image
        else { return }
        let newImageView = UIImageView(image: originalImage)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let promptLabel = UILabel()
        promptLabel.text = "Tap to dismiss"
        promptLabel.textColor = UIColor(named: "G3")
        promptLabel.font = UIFont(name: "PingFangTC", size: 16)
        newImageView.addSubview(promptLabel)
        promptLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            promptLabel.bottomAnchor.constraint(equalTo: newImageView.bottomAnchor, constant: -180),
            promptLabel.centerXAnchor.constraint(equalTo: newImageView.centerXAnchor)
        ])
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(handleZoomGesture(_:)))
        newImageView.addGestureRecognizer(pinch)
        view.addSubview(newImageView)
    }
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    // 檢測到捏合手勢時被調用
    @objc func handleZoomGesture(_ gestureRecognizer: UIPinchGestureRecognizer) {
        guard let view = gestureRecognizer.view else { return }
        if gestureRecognizer.state == .changed || gestureRecognizer.state == .ended {
            view.transform = view.transform.scaledBy(x: gestureRecognizer.scale, y: gestureRecognizer.scale)
            // 應用縮放變換后，手勢的縮放比例將重置為 1.0。這樣做是為了防止累積縮放，確保每個捏合手勢都得到獨立處理。
            gestureRecognizer.scale = 1.0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let chatMessage = chatMessages[indexPath.row]
        if chatMessages[indexPath.row].imageURL != "" {
            let isMe = chatMessage.buyerID == Auth.auth().currentUser?.uid
            if isMe == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as! ImageCell
                let chatMessage = chatMessages[indexPath.row]
                cell.backgroundColor = .black
                cell.configure(with: chatMessage)
                if let imagePost = URL(string: chatMessage.imageURL ?? "") {
                    cell.imageURLpost.kf.setImage(with: imagePost)
                }
                let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
                cell.imageURLpost.addGestureRecognizer(tap)
                cell.timestampLabel.textAlignment = .right
                cell.image.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10).isActive = true
                cell.image.leadingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -40).isActive = true
                cell.timestampLabel.trailingAnchor.constraint(equalTo: cell.imageURLpost.leadingAnchor, constant: -20).isActive = true
                cell.imageURLpost.trailingAnchor.constraint(equalTo: cell.image.leadingAnchor, constant: -15).isActive = true
                cell.image.widthAnchor.constraint(equalToConstant: 30).isActive = true
                cell.image.heightAnchor.constraint(equalToConstant: 30).isActive = true
                cell.timestampLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5).isActive = true
                cell.imageURLpost.widthAnchor.constraint(equalToConstant: 200).isActive = true
                cell.imageURLpost.heightAnchor.constraint(equalToConstant: 200).isActive = true
                cell.nameLabel.centerXAnchor.constraint(equalTo: cell.image.centerXAnchor).isActive = true
                cell.nameLabel.topAnchor.constraint(equalTo: cell.image.bottomAnchor, constant: 5).isActive = true
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "leftImageCell", for: indexPath) as! LeftImageCell
                let chatMessage = chatMessages[indexPath.row]
                cell.backgroundColor = .black
                cell.configure(with: chatMessage)
                if let imagePost = URL(string: chatMessage.imageURL ?? "") {
                    cell.imageURLpost.kf.setImage(with: imagePost)
                }
                let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
                cell.imageURLpost.addGestureRecognizer(tap)
                cell.timestampLabel.textAlignment = .left
                cell.image.leadingAnchor.constraint(equalTo: cell.trailingAnchor, constant: 10).isActive = true
                cell.image.trailingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 40).isActive = true
                cell.timestampLabel.leadingAnchor.constraint(equalTo: cell.imageURLpost.trailingAnchor, constant: 20).isActive = true
                cell.imageURLpost.leadingAnchor.constraint(equalTo: cell.image.trailingAnchor, constant: 15).isActive = true
                cell.image.widthAnchor.constraint(equalToConstant: 30).isActive = true
                cell.image.heightAnchor.constraint(equalToConstant: 30).isActive = true
                cell.timestampLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5).isActive = true
                cell.imageURLpost.widthAnchor.constraint(equalToConstant: 200).isActive = true
                cell.imageURLpost.heightAnchor.constraint(equalToConstant: 200).isActive = true
                cell.nameLabel.centerXAnchor.constraint(equalTo: cell.image.centerXAnchor).isActive = true
                cell.nameLabel.topAnchor.constraint(equalTo: cell.image.bottomAnchor, constant: 5).isActive = true
                return cell
            }
        } else if chatMessage.audioURL != "" {
            let isMe = chatMessage.buyerID == Auth.auth().currentUser?.uid
            if isMe == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "voiceCell", for: indexPath) as! VoiceCell
                cell.backgroundColor = .black
                let audioURL = chatMessage.audioURL
                cell.configure(with: audioURL, chatMessage: chatMessage)
                NSLayoutConstraint.activate([
                    cell.image.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
                    cell.image.leadingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -40),
                    cell.image.widthAnchor.constraint(equalToConstant: 30),
                    cell.image.heightAnchor.constraint(equalToConstant: 30),
                    cell.nameLabel.centerXAnchor.constraint(equalTo: cell.image.centerXAnchor),
                    cell.nameLabel.topAnchor.constraint(equalTo: cell.image.bottomAnchor, constant: 5),
                    cell.backView.heightAnchor.constraint(equalToConstant: 50),
                    cell.backView.widthAnchor.constraint(equalToConstant: 200),
                    cell.backView.trailingAnchor.constraint(equalTo: cell.image.leadingAnchor,constant: -20),
                    cell.backView.topAnchor.constraint(equalTo: cell.image.topAnchor, constant: 10),
                    cell.playButton.centerYAnchor.constraint(equalTo: cell.backView.centerYAnchor),
                    cell.playButton.leadingAnchor.constraint(equalTo: cell.backView.leadingAnchor, constant: 20),
                    cell.timestampLabel.bottomAnchor.constraint(equalTo: cell.backView.bottomAnchor, constant: -5),
                    cell.timestampLabel.trailingAnchor.constraint(equalTo: cell.backView.leadingAnchor, constant: -20)
                ])
                cell.backView.backgroundColor = chatMessage.buyerID == Auth.auth().currentUser?.uid ? UIColor(named: "G4") : UIColor(named: "G5")
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "leftVoiceCell", for: indexPath) as! LeftVoiceCell
                cell.backgroundColor = .black
                let audioURL = chatMessage.audioURL
                cell.configure(with: audioURL, chatMessage: chatMessage)
                NSLayoutConstraint.activate([
                    cell.image.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10),
                    cell.image.trailingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 40),
                    cell.image.widthAnchor.constraint(equalToConstant: 30),
                    cell.image.heightAnchor.constraint(equalToConstant: 30),
                    cell.nameLabel.centerXAnchor.constraint(equalTo: cell.image.centerXAnchor),
                    cell.nameLabel.topAnchor.constraint(equalTo: cell.image.bottomAnchor, constant: 5),
                    cell.backView.heightAnchor.constraint(equalToConstant: 50),
                    cell.backView.widthAnchor.constraint(equalToConstant: 200),
                    cell.backView.leadingAnchor.constraint(equalTo: cell.image.trailingAnchor,constant: 20),
                    cell.backView.topAnchor.constraint(equalTo: cell.image.topAnchor, constant: 10),
                    cell.playButton.centerYAnchor.constraint(equalTo: cell.backView.centerYAnchor),
                    cell.playButton.leadingAnchor.constraint(equalTo: cell.backView.leadingAnchor, constant: 20),
                    cell.timestampLabel.bottomAnchor.constraint(equalTo: cell.backView.bottomAnchor, constant: -5),
                    cell.timestampLabel.leadingAnchor.constraint(equalTo: cell.backView.trailingAnchor, constant: 20)
                ])
                cell.backView.backgroundColor = chatMessage.buyerID == Auth.auth().currentUser?.uid ? UIColor(named: "G4") : UIColor(named: "G5")
                return cell
            }
        } else {
            let isMe = chatMessage.buyerID == Auth.auth().currentUser?.uid
            if isMe == true {
                let cell = tableView.dequeueReusableCell(withIdentifier: "textCell", for: indexPath) as! TextCell
                let chatMessage = chatMessages[indexPath.row]
                cell.backgroundColor = .black
                cell.configure(with: chatMessage)
                cell.messageLabel.text = chatMessage.text
                cell.messageLabel.textColor = chatMessage.buyerID == Auth.auth().currentUser?.uid ? .white : .white
                cell.messageLabel.textAlignment = chatMessage.buyerID == Auth.auth().currentUser?.uid ? .left : .left
                NSLayoutConstraint.activate([
                    cell.image.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -10),
                    cell.image.leadingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -40),
                    cell.messageLabel.trailingAnchor.constraint(equalTo: cell.image.leadingAnchor, constant: -20),
                    cell.timestampLabel.trailingAnchor.constraint(equalTo: cell.messageLabel.leadingAnchor, constant: -20),
                    cell.image.widthAnchor.constraint(equalToConstant: 30),
                    cell.image.heightAnchor.constraint(equalToConstant: 30),
                    cell.messageLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10),
                    cell.messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 180),
                    cell.messageLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5),
                    cell.timestampLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5),
                    cell.nameLabel.centerXAnchor.constraint(equalTo: cell.image.centerXAnchor),
                    cell.nameLabel.topAnchor.constraint(equalTo: cell.image.bottomAnchor, constant: 5),
                ])
                // 清除或重置 backgroundViewCloud，以防止重複使用時的問題
                for subview in cell.subviews {
                    if subview is UIImageView {
                        subview.removeFromSuperview()
                    }
                }
                let backgroundViewCloud = UIImageView()
                backgroundViewCloud.contentMode = .scaleToFill
                cell.addSubview(backgroundViewCloud)
                cell.sendSubviewToBack(backgroundViewCloud)
                backgroundViewCloud.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    backgroundViewCloud.topAnchor.constraint(equalTo: cell.messageLabel.topAnchor, constant: -10),
                    backgroundViewCloud.leadingAnchor.constraint(equalTo: cell.messageLabel.leadingAnchor, constant: -20),
                    backgroundViewCloud.bottomAnchor.constraint(equalTo: cell.messageLabel.bottomAnchor, constant: 2),
                    backgroundViewCloud.trailingAnchor.constraint(equalTo: cell.messageLabel.trailingAnchor, constant: 15)
                ])
                if chatMessage.buyerID == Auth.auth().currentUser?.uid {
                    backgroundViewCloud.image = UIImage(named: "S3")
                } else {
                    backgroundViewCloud.image = UIImage(named: "S1")
                }
                cell.messageLabel.numberOfLines = 0
                cell.messageLabel.layer.cornerRadius = 10
                cell.messageLabel.layer.masksToBounds = true
                if let mapLink = cell.messageLabel.text, let url = URL(string: mapLink) {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openMap(_:)))
                    cell.messageLabel.isUserInteractionEnabled = true
                    cell.messageLabel.addGestureRecognizer(tapGesture)
                }
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "lefttextCell", for: indexPath) as! LeftTextCell
                let chatMessage = chatMessages[indexPath.row]
                cell.backgroundColor = .black
                cell.configure(with: chatMessage)
                cell.messageLabel.text = chatMessage.text
                cell.messageLabel.textColor = chatMessage.buyerID == Auth.auth().currentUser?.uid ? .white : .white
                cell.messageLabel.textAlignment = chatMessage.buyerID == Auth.auth().currentUser?.uid ? .left : .left
                NSLayoutConstraint.activate([
                    cell.image.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 10),
                    cell.image.trailingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 40),
                    cell.messageLabel.leadingAnchor.constraint(equalTo: cell.image.trailingAnchor, constant: 20),
                    cell.timestampLabel.leadingAnchor.constraint(equalTo: cell.messageLabel.trailingAnchor, constant: 20),
                    cell.image.widthAnchor.constraint(equalToConstant: 30),
                    cell.image.heightAnchor.constraint(equalToConstant: 30),
                    cell.messageLabel.topAnchor.constraint(equalTo: cell.topAnchor, constant: 10),
                    cell.messageLabel.widthAnchor.constraint(lessThanOrEqualToConstant: 180),
                    cell.messageLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5),
                    cell.timestampLabel.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -5),
                    cell.nameLabel.centerXAnchor.constraint(equalTo: cell.image.centerXAnchor),
                    cell.nameLabel.topAnchor.constraint(equalTo: cell.image.bottomAnchor, constant: 5)
                ])
                // 清除或重置 backgroundViewCloud，以防止重複使用時的問題
                for subview in cell.subviews {
                    if subview is UIImageView {
                        subview.removeFromSuperview()
                    }
                }
                let backgroundViewCloud = UIImageView()
                backgroundViewCloud.contentMode = .scaleToFill
                cell.addSubview(backgroundViewCloud)
                cell.sendSubviewToBack(backgroundViewCloud)
                backgroundViewCloud.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    backgroundViewCloud.topAnchor.constraint(equalTo: cell.messageLabel.topAnchor, constant: -4),
                    backgroundViewCloud.leadingAnchor.constraint(equalTo: cell.messageLabel.leadingAnchor, constant: -20),
                    backgroundViewCloud.bottomAnchor.constraint(equalTo: cell.messageLabel.bottomAnchor, constant: 2),
                    backgroundViewCloud.trailingAnchor.constraint(equalTo: cell.messageLabel.trailingAnchor, constant: 15)
                ])
                if chatMessage.buyerID == Auth.auth().currentUser?.uid {
                    backgroundViewCloud.image = UIImage(named: "S3")
                } else {
                    backgroundViewCloud.image = UIImage(named: "S1")
                }
                cell.messageLabel.numberOfLines = 0
                cell.messageLabel.layer.cornerRadius = 10
                cell.messageLabel.layer.masksToBounds = true
                if let mapLink = cell.messageLabel.text, let url = URL(string: mapLink) {
                    let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openMap(_:)))
                    cell.messageLabel.isUserInteractionEnabled = true
                    cell.messageLabel.addGestureRecognizer(tapGesture)
                }
                return cell
            }
        }
    }
    @objc func openMap(_ gesture: UITapGestureRecognizer) {
        // gesture.view 獲取到正確的
        guard let tappedCell = gesture.view as? UILabel, let mapLink = tappedCell.text, let url = URL(string: mapLink) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let minHeight: CGFloat = 200 // 設定最小高度為 200
        let chatMessage = chatMessages[indexPath.row]
        if ((chatMessage.imageURL?.isEmpty) == false) {
            return minHeight // 如果是圖片消息，直接返回最小高度
        } else if chatMessage.audioURL?.isEmpty == false {
            return 70
        } else {
            let minHeight: CGFloat = 80
            let dynamicHeight = calculateDynamicHeight(for: indexPath)
            return max(dynamicHeight, minHeight)
        }
    }
    private func calculateDynamicHeight(for indexPath: IndexPath) -> CGFloat {
        let content = chatMessages[indexPath.row].text
        let font = UIFont.systemFont(ofSize: 15)
        let boundingBox = CGSize(width: tableView.bounds.width - 140, height: .greatestFiniteMagnitude)
        let size = content.boundingRect(with: boundingBox, options: [.usesLineFragmentOrigin, .usesFontLeading], attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(size.height) + 50
    }
}
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
          if let selectedImage = info[.editedImage] as? UIImage {
              uploadFixedImage(selectedImage) { [weak self] imageURL in
                  self?.sendMessageToFirestore("", isMe: true, imageURL: imageURL, location: nil)
              }
          }
          picker.dismiss(animated: true, completion: nil)
      }

      func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
          picker.dismiss(animated: true, completion: nil)
      }
}
extension ChatViewController: MapSelectionDelegate {
    func didSelectLocation(_ coordinate: CLLocationCoordinate2D) {
        sendLocationToFirestore(coordinate)
    }
}
extension ChatViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last?.coordinate else { return }
        currentLocation = location
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
}
