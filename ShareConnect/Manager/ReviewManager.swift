//
//  ReviewManager.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/23.
//

import FirebaseFirestore
import FirebaseAuth

class ReviewManager {
    static let shared = ReviewManager()

    private init() {}

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
