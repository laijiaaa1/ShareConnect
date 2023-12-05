//
//  SignInViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/30.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import FirebaseStorage

class RegistrationViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let db = Firestore.firestore()
    lazy var emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    lazy var passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
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
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1.0)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectProfilePicture))
        profileImageView.addGestureRecognizer(imageTapGesture)
    }
    func setupUI() {
        view.backgroundColor = CustomColors.B1
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(nameTextField)
        view.addSubview(profileImageView)
        view.addSubview(registerButton)
        profileImageView.image = UIImage(named: "icons8-user-48(@3×)")
        profileImageView.layer.cornerRadius = 50
        profileImageView.layer.masksToBounds = true
        profileImageView.tintColor = .gray
        NSLayoutConstraint.activate([
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 120),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 20),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            nameTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            nameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            nameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            nameTextField.heightAnchor.constraint(equalToConstant: 40),
            profileImageView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 40),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            registerButton.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 60),
            registerButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 60),
            registerButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            registerButton.heightAnchor.constraint(equalToConstant: 40),
        ])
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
        }
        picker.dismiss(animated: true, completion: nil)
    }
    // MARK: - Actions
    @objc func registerButtonTapped() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let name = nameTextField.text,
              let profileImage = profileImageView.image else {
            return
        }
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            if let error = error {
                print("Error creating user: \(error.localizedDescription)")
            } else {
                self.uploadProfileImage(profileImage) { imageUrl in
                    guard let uid = Auth.auth().currentUser?.uid else {
                        return
                    }
                    self.db.collection("users").document(uid).setData([
                        "email": email,
                        "name": name,
                        "profileImageUrl": imageUrl,
                    ]) { error in
                        if let error = error {
                            print("Error adding user to Firestore: \(error.localizedDescription)")
                        } else {
                            print("User added to Firestore successfully")
                            if let buyerID = Auth.auth().currentUser?.uid {
                                Messaging.messaging().subscribe(toTopic: buyerID)
                            }
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                            self.navigationController?.pushViewController(vc, animated: true)
                        }
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
            } else {
                storageRef.downloadURL { url, error in
                    if let error = error {
                        print("Error getting download URL: \(error.localizedDescription)")
                    } else {
                        guard let url = url else {
                            return
                        }
                        completion(url.absoluteString)
                    }
                }
            }
        }
    }
}
