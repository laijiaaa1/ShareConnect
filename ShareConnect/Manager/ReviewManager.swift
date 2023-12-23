//
//  ReviewManager.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/23.
//

import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class ReviewManager {
    static let shared = ReviewManager()
    private init() {}
    func submitReview (
        for productID: String,
        sellerID: String,
        comment: String?,
        rating: Double,
        image: UIImage?,
        completion: @escaping (Bool) -> Void
    ) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let reviewsCollection = Firestore.firestore().collection("reviews")
        let reviewID = reviewsCollection.document().documentID
        var reviewData: [String: Any] = [
            "userID": currentUserID,
            "productID": productID,
            "comment": comment ?? "",
            "rating": rating,
            "timestamp": Date(),
            "sellerID": sellerID
        ]
        if let image = image, let imageData = image.jpegData(compressionQuality: 0.5) {
            let imageStorageRef = Storage.storage().reference().child("review_images/\(reviewID).jpg")
            imageStorageRef.putData(imageData, metadata: nil) { (_, error) in
                if let error = error {
                    print("Error uploading image: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                imageStorageRef.downloadURL { (url, error) in
                    guard let imageUrl = url?.absoluteString else {
                        print("Error getting image URL: \(error?.localizedDescription ?? "")")
                        completion(false)
                        return
                    }
                    reviewData["image"] = imageUrl
                    // Save review data to Firestore
                    self.saveReviewData(reviewData, reviewID: reviewID, completion: completion)
                }
            }
        } else {
            // Save review data to Firestore without an image
            self.saveReviewData(reviewData, reviewID: reviewID, completion: completion)
        }
    }
    private func saveReviewData(_ reviewData: [String: Any], reviewID: String, completion: @escaping (Bool) -> Void) {
        let reviewsCollection = Firestore.firestore().collection("reviews")
        reviewsCollection.document(reviewID).setData(reviewData) { error in
            if let error = error {
                print("Error adding review: \(error.localizedDescription)")
                completion(false)
            } else {
                print("Review added successfully!")
                completion(true)
            }
        }
    }
    func fetchReviews(for sellerID: String, completion: @escaping ([Reviews]) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion([])
            return
        }
        let reviewsCollection = Firestore.firestore().collection("reviews")
        reviewsCollection.whereField("sellerID", isEqualTo: sellerID).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error fetching reviews: \(error.localizedDescription)")
                completion([])
                return
            }
            let reviews = querySnapshot?.documents.compactMap { document in
                return Reviews(document: document)
            } ?? []
            DispatchQueue.main.async {
                completion(reviews)
            }
        }
    }
    func hasUserReviewedProduct(_ orderID: String, completion: @escaping (Bool) -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            completion(false)
            return
        }
        let reviewsCollection = Firestore.firestore().collection("reviews")
        reviewsCollection.whereField("userID", isEqualTo: currentUserID)
            .whereField("productID", isEqualTo: orderID)
            .getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error fetching reviews: \(error.localizedDescription)")
                    completion(false)
                    return
                }
                let hasReview = !(querySnapshot?.documents.isEmpty ?? false)
                completion(hasReview)
            }
    }
}
