//
//  AppleInfoViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/15.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import FirebaseStorage
import ProgressHUD
import AuthenticationServices

class AppleInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let db = Firestore.firestore()
    var appleIDCredential: ASAuthorizationAppleIDCredential?
    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Name"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.isUserInteractionEnabled = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    lazy var registerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Send", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectProfilePicture))
        profileImageView.addGestureRecognizer(imageTapGesture)
    }
    func setupUI() {
        view.addSubview(nameTextField)
        view.addSubview(profileImageView)
        view.addSubview(registerButton)
        nameTextField.backgroundColor = .white
        nameTextField.borderStyle = .none
        profileImageView.layer.cornerRadius = 70
        profileImageView.layer.masksToBounds = true
        profileImageView.tintColor = .gray
        profileImageView.backgroundColor = .clear
        let addImageLabel = UILabel()
        view.addSubview(addImageLabel)
        addImageLabel.text = "Tap to add your image"
        addImageLabel.textColor = .white
        addImageLabel.translatesAutoresizingMaskIntoConstraints = false
        let cancelButton = UIButton()
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.systemBlue, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        NSLayoutConstraint.activate([
            nameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 70),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            profileImageView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 30),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 140),
            profileImageView.heightAnchor.constraint(equalToConstant: 140),
            addImageLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: -75),
            addImageLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            addImageLabel.widthAnchor.constraint(equalToConstant: 200),
            registerButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 40),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            registerButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: 20),
            cancelButton.centerXAnchor.constraint(equalTo: registerButton.centerXAnchor),
            cancelButton.heightAnchor.constraint(equalToConstant: 50),
            cancelButton.widthAnchor.constraint(equalToConstant: 70)
        ])
    }
    @objc func cancelButtonTapped() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    @objc func selectProfilePicture() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    // MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImageView.image = pickedImage
            profileImageView.contentMode = .scaleAspectFill
            profileImageView.clipsToBounds = true
        }
        picker.dismiss(animated: true, completion: nil)
    }
    // MARK: - Actions
    @objc func registerButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text,
              let profileImage = profileImageView.image,
              let appleIDCredential = self.appleIDCredential else {
            return
        }
        ProgressHUD.animate("Please wait...", .ballVerticalBounce)
        uploadProfileImage(profileImage) { imageUrl in
            let uid = Auth.auth().currentUser?.uid ?? ""
            guard !uid.isEmpty else {
                print("Unable to get UID from Apple Sign In")
                return
            }
            self.db.collection("users").document(uid).setData([
                "name": name,
                "profileImageUrl": imageUrl
            ]) { error in
                if let error = error {
                    print("Error updating user data in Firestore: \(error.localizedDescription)")
                } else {
                    print("User data updated in Firestore successfully")
                    if let buyerID = Auth.auth().currentUser?.uid {
                        Messaging.messaging().subscribe(toTopic: buyerID)
                    }
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController {
                        self.navigationController?.pushViewController(tabBarController, animated: true)
                    }
                    DispatchQueue.main.async {
                        ProgressHUD.succeed("Success", delay: 1.5)
                    }
                }
            }
        }
    }
    func uploadProfileImage(_ image: UIImage, completion: @escaping (String) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return
        }
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("Error uploading profile image: \(error.localizedDescription)")
                completion("") // Pass an empty string to indicate failure
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                        completion("") // Pass an empty string to indicate failure
                    } else {
                        guard let url = url else {
                            completion("") // Pass an empty string to indicate failure
                            return
                        }
                        completion(url.absoluteString)
                    }
                }
            }
        }
    }
}
