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
import ProgressHUD

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
        view.backgroundColor = .black
        setupUI()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
        let imageTapGesture = UITapGestureRecognizer(target: self, action: #selector(selectProfilePicture))
        profileImageView.addGestureRecognizer(imageTapGesture)
    }
    func setupUI() {
        let backPicture = UIImageView()
        backPicture.image = UIImage(named: "7")
        backPicture.frame = CGRect(x: 0, y: 20, width: view.frame.width, height: view.frame.height - 40)
        view.addSubview(backPicture)
        view.sendSubviewToBack(backPicture)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(nameTextField)
        view.addSubview(profileImageView)
        view.addSubview(registerButton)
        emailTextField.backgroundColor = .clear
        passwordTextField.backgroundColor = .clear
        nameTextField.backgroundColor = .clear
        emailTextField.borderStyle = .none
        passwordTextField.borderStyle = .none
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
            emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 125),
            emailTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 70),
            emailTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            emailTextField.heightAnchor.constraint(equalToConstant: 40),
            passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 30),
            passwordTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 70),
            passwordTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -60),
            passwordTextField.heightAnchor.constraint(equalToConstant: 40),
            nameTextField.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 22),
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
    @objc func registerButtonTapped() {
        guard let email = emailTextField.text,
              let password = passwordTextField.text,
              let name = nameTextField.text,
              let profileImage = profileImageView.image else {
            showAlertWith(title: "錯誤", message: "請填寫所有欄位。")
                   return
        }
        guard password.count >= 6 else {
               showAlertWith(title: "密碼太短", message: "密碼必須至少為6碼。")
               return
           }
        guard isValidEmail(email) else {
             showAlertWith(title: "無效的電子郵件", message: "請輸入有效且完整的電子郵件地址。")
             return
         }
        RegistrationManager.shared.registerUser(email: email, password: password, name: name, profileImage: profileImage) { success in
            if success {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "LoginViewController")
                DispatchQueue.main.async {
                    ProgressHUD.succeed("Regist Success", delay: 1.5)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            } else {
                print("Registration failed")
            }
        }
    }
    func showAlertWith(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "確定", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}
