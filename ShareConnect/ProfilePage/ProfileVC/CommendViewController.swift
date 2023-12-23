//
//  CommendViewController.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/25.
//

import UIKit
import Kingfisher
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseFirestore
import ProgressHUD

class CommendViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    var productName: String?
    var productImage: String?
    var productID: String?
    var sellerID: String = ""
    let commentTextView = UITextView()
    let imageView = UIImageView()
    let starRatingView = StarRatingView()
    let submitButton = UIButton()
    let addImageButton = UIButton()
    let nameLable = UILabel()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationItem.title = "COMMENT"
        imageView.kf.setImage(with: URL(string: productImage ?? ""))
        submitButton.setTitle("Submit Commect", for: .normal)
        submitButton.addTarget(self, action: #selector(submitReview), for: .touchUpInside)
        setup()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    func setup() {
        let backView = UIView()
        view.addSubview(backView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            backView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            backView.heightAnchor.constraint(equalToConstant: 500)
        ])
        backView.backgroundColor = .black
        backView.layer.cornerRadius = 10
        backView.layer.borderWidth = 1
        backView.layer.masksToBounds = true
        backView.addSubview(imageView)
        backView.addSubview(commentTextView)
        backView.addSubview(starRatingView)
        backView.addSubview(addImageButton)
        backView.addSubview(nameLable)
        nameLable.translatesAutoresizingMaskIntoConstraints = false
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        starRatingView.translatesAutoresizingMaskIntoConstraints = false
        addImageButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: backView.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20),
            imageView.heightAnchor.constraint(equalToConstant: 80),
            imageView.widthAnchor.constraint(equalToConstant: 80),
            nameLable.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            nameLable.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 20),
            nameLable.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -20),
            starRatingView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            starRatingView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20),
            starRatingView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -20),
            starRatingView.heightAnchor.constraint(equalToConstant: 50),
            commentTextView.topAnchor.constraint(equalTo: starRatingView.bottomAnchor, constant: 20),
            commentTextView.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20),
            commentTextView.trailingAnchor.constraint(equalTo: backView.trailingAnchor, constant: -20),
            commentTextView.heightAnchor.constraint(equalToConstant: 200),
            addImageButton.topAnchor.constraint(equalTo: commentTextView.bottomAnchor, constant: 20),
            addImageButton.leadingAnchor.constraint(equalTo: backView.leadingAnchor, constant: 20),
            addImageButton.heightAnchor.constraint(equalToConstant: 50),
            addImageButton.widthAnchor.constraint(equalToConstant: 50)
        ])
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 10
        imageView.layer.borderWidth = 1
        imageView.layer.masksToBounds = true
        commentTextView.layer.cornerRadius = 10
        commentTextView.layer.masksToBounds = true
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = UIColor.black.cgColor
        commentTextView.font = UIFont.systemFont(ofSize: 16)
        starRatingView.backgroundColor = .black
        addImageButton.setTitle("+", for: .normal)
        addImageButton.setTitleColor(UIColor(named: "G3"), for: .normal)
        addImageButton.backgroundColor = .white
        addImageButton.layer.cornerRadius = 25
        addImageButton.layer.masksToBounds = true
        addImageButton.layer.borderWidth = 1
        addImageButton.layer.borderColor = UIColor.black.cgColor
        nameLable.text = productName
        nameLable.textColor = .white
        nameLable.font = UIFont.boldSystemFont(ofSize: 16)
        nameLable.textAlignment = .left
        nameLable.numberOfLines = 0
        addImageButton.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        view.addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 20),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        submitButton.backgroundColor = UIColor(named: "G3")
        submitButton.layer.cornerRadius = 10
        submitButton.layer.masksToBounds = true
        submitButton.layer.borderWidth = 1
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.startAnimatingPressActions()
    }
    @objc func addImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        let alertController = UIAlertController(title: "Choose Image Source", message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { _ in
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true)
            }
            alertController.addAction(cameraAction)
        }
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { _ in
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true)
        }
        alertController.addAction(photoLibraryAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            addImageButton.setBackgroundImage(selectedImage, for: .normal)
        }
        dismiss(animated: true, completion: nil)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    @objc func submitReview() {
        ReviewManager.shared.submitReview(
            for: productID ?? "",
            sellerID: sellerID,
            comment: commentTextView.text,
            rating: Double(starRatingView.rating),
            image: imageView.image
        ) { success in
            if success {
                DispatchQueue.main.async {
                    ProgressHUD.succeed("Comment Success", delay: 1.5)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            } else {
                print("Failed to submit review.")
            }
        }
    }
}
