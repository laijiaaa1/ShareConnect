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

struct Commend{
    var comment: String
    var rating: Int
    var image: String
    var sellerID: String
    var buyerID: String
    var productID: String
    var time: String
}
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
        view.backgroundColor = CustomColors.B1
        navigationItem.title = "COMMEND"
        imageView.kf.setImage(with: URL(string: productImage ?? ""))
        submitButton.setTitle("Submit Review", for: .normal)
        submitButton.addTarget(self, action: #selector(submitReview), for: .touchUpInside)
        setup()
    }
    func setup(){
        let backView = UIView()
        view.addSubview(backView)
        backView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backView.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            backView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            backView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            backView.heightAnchor.constraint(equalToConstant: 500)
        ])
        backView.backgroundColor = .white
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
            nameLable.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 10),
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
            addImageButton.widthAnchor.constraint(equalToConstant: 50),
        ])
        imageView.contentMode = .scaleToFill
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        commentTextView.layer.cornerRadius = 10
        commentTextView.layer.masksToBounds = true
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = UIColor.black.cgColor
        commentTextView.font = UIFont.systemFont(ofSize: 15)
        starRatingView.backgroundColor = .white
        starRatingView.layer.cornerRadius = 10
        starRatingView.layer.masksToBounds = true
        addImageButton.setTitle("+", for: .normal)
        addImageButton.setTitleColor(.black, for: .normal)
        addImageButton.backgroundColor = .white
        addImageButton.layer.cornerRadius = 25
        addImageButton.layer.masksToBounds = true
        addImageButton.layer.borderWidth = 1
        addImageButton.layer.borderColor = UIColor.black.cgColor
        nameLable.text = productName
        nameLable.textColor = .black
        nameLable.font = UIFont.boldSystemFont(ofSize: 15)
        nameLable.textAlignment = .left
        nameLable.numberOfLines = 0
        addImageButton.addTarget(self, action: #selector(addImage), for: .touchUpInside)
        view.addSubview(submitButton)
        submitButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            submitButton.topAnchor.constraint(equalTo: backView.bottomAnchor, constant: 20),
            submitButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            submitButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            submitButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        submitButton.backgroundColor = .white
        submitButton.layer.cornerRadius = 10
        submitButton.layer.masksToBounds = true
        submitButton.layer.borderWidth = 1
        submitButton.setTitleColor(.black, for: .normal)
    }
    @objc func addImage(){
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
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }

        let textComment = commentTextView.text
        let uploadedImage = imageView.image
        let starRating = starRatingView.rating

        let reviewsCollection = Firestore.firestore().collection("reviews")
        let reviewID = reviewsCollection.document().documentID
        let imageStorageRef = Storage.storage().reference().child("review_images/\(reviewID).jpg")
        if let image = uploadedImage, let imageData = image.jpegData(compressionQuality: 0.5) {
            imageStorageRef.putData(imageData, metadata: nil) { (_, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    return
                }
                imageStorageRef.downloadURL { (url, error) in
                    guard let imageUrl = url?.absoluteString else {
                        print("Error getting image URL: \(error?.localizedDescription ?? "")")
                        return
                    }
                    let reviewData: [String: Any] = [
                        "userID": currentUserID,
                        "productID": self.productID ?? "",
                        "comment": textComment ?? "",
                        "rating": starRating,
                        "image": imageUrl,
                        "timestamp": Date(),
                        "sellerID": self.sellerID,
                    ]

                    reviewsCollection.document(reviewID).setData(reviewData) { error in
                        if let error = error {
                            print("Error adding review: \(error.localizedDescription)")
                        } else {
                            print("Review added successfully!")
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        } else {
            let reviewData: [String: Any] = [
                "userID": currentUserID,
                "productID": productID ?? "",
                "comment": textComment ?? "",
                "rating": starRating,
                "timestamp": Date(),
                "sellerID": sellerID,
            ]

            reviewsCollection.document(reviewID).setData(reviewData) { error in
                if let error = error {
                    print("Error adding review: \(error.localizedDescription)")
                } else {
                    print("Review added successfully!")
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }

}
class StarRatingView: UIView {
    var rating: Int = 0 {
        didSet {
            setNeedsLayout()
        }
    }
    var ratingButtons = [UIButton]()
    var spacing = 5
    var stars = 5
    override var intrinsicContentSize: CGSize {
        let buttonSize = Int(frame.size.height)
        let width = (buttonSize + spacing) * stars
        return CGSize(width: width, height: buttonSize)
    }
    override func layoutSubviews() {
        var buttonFrame = CGRect(x: 0, y: 0, width: 50, height: 50)
        for (index, button) in ratingButtons.enumerated() {
            buttonFrame.origin.x = CGFloat(index * (50 + spacing))
            button.frame = buttonFrame
        }
        updateButtonSelectionStates()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        spacing = 5
        stars = 5
        setupButtons()
    }
    required init(coder: NSCoder) {
        super.init(coder: coder)!
        spacing = 5
        stars = 5
        setupButtons()
    }
    private func setupButtons() {
        for _ in 0..<stars {
            let button = UIButton()
            button.backgroundColor = .white
            button.tintColor = .black
            button.setImage(UIImage(systemName: "star"), for: .normal)
            button.setImage(UIImage(systemName: "star.fill"), for: .selected)
            button.adjustsImageWhenHighlighted = false
            button.addTarget(self, action: #selector(ratingButtonTapped(button:)), for: .touchUpInside)
            ratingButtons.append(button)
            addSubview(button)
        }
    }
    @objc func ratingButtonTapped(button: UIButton) {
        guard let index = ratingButtons.firstIndex(of: button) else {
            fatalError("The button, \(button), is not in the ratingButtons array: \(ratingButtons)")
        }
        let selectedRating = index + 1
        if selectedRating == rating {
            rating = 0
        } else {
            rating = selectedRating
        }
    }
    private func updateButtonSelectionStates() {
        for (index, button) in ratingButtons.enumerated() {
            button.isSelected = index < rating
        }
    }
}
