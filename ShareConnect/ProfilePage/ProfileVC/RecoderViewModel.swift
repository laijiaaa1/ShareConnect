//
//  RecoderViewModel.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/24.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore

class RecoderViewModel {
    var orderID: [Order] = []
    var numberOfRows: Int {
        return orderID.count
    }
    func order(at index: Int) -> Order {
        return orderID[index]
    }
    func fetchOrdersFromFirestore(isRenter: Bool, completion: @escaping () -> Void) {
        guard let currentUserID = Auth.auth().currentUser?.uid else {
            return
        }
        let ordersCollection = Firestore.firestore().collection("orders")
        let fieldToFilter = isRenter ? "buyerID" : "sellerID"
        ordersCollection.whereField(fieldToFilter, isEqualTo: currentUserID).getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self, let querySnapshot = querySnapshot else {
                return
            }
            if let error = error {
                print("Error fetching orders: \(error.localizedDescription)")
                return
            }
            self.orderID = querySnapshot.documents.compactMap { Order(document: $0) }
            completion()
        }
    }
    func hasUserReviewedItem(at index: Int, completion: @escaping (Bool) -> Void) {
        ReviewManager.shared.hasUserReviewedProduct(orderID[index].orderID) { hasReview in
            DispatchQueue.main.async {
                completion(hasReview)
            }
        }
    }
}
