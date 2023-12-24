//
//  CommendViewModel.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/23.
//

import Foundation
import UIKit

class CommendViewModel {
    var productName: String?
    var productImage: String?
    var productID: String?
    var sellerID: String = ""

    func submitReview(comment: String, rating: Double, image: UIImage?, completion: @escaping (Bool) -> Void) {
        ReviewManager.shared.submitReview(
            for: productID ?? "",
            sellerID: sellerID,
            comment: comment,
            rating: rating,
            image: image
        ) { success in
            completion(success)
        }
    }
}
