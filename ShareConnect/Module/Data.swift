//
//  Data.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/18.
//

import Foundation

struct Product {
//    let productId: String
    let name: String
    let price: String
    let startTime: String
    let imageString: String
    let description: String?
    let sort: String?
    let quantity: String?
    let use: String?
    let endTime: String?
    let seller: Seller
    let itemType: ProductType
}
//extension Product: Equatable {
//    static func == (lhs: Product, rhs: Product) -> Bool {
//        // Implement the equality comparison based on your requirements
//        return lhs.productId == rhs.productId
//    }
//}


enum ProductType: String {
    case request
    case supply
}


struct Seller: Hashable {
    var sellerID: String
    var sellerName: String
}

struct Request {
    let requestID: String
    let buyerID: String
    let items: [Product]
    let selectedSellerID: String?
    let status: RequestStatus
}

enum RequestStatus {
    case open
    case closed
}

protocol TrolleyCellDelegate: AnyObject {
    func didSelectSeller(sellerID: String)
}

struct UserData {
    var userID: String
    var username: String
}

//let seller = Seller(sellerID: "123", sellerName: "Seller Name")
//
//let demandProduct = Product(name: "Demand Product", price: "50", startTime: "2023-11-30", imageString: "demandImageURL", description: "Demand Description", sort: "Electronics", quantity: "10", use: "New", endTime: "2023-12-31", seller: seller, itemType: .request)
//
//let supplyProduct = Product(name: "Supply Product", price: "30", startTime: "2023-11-30", imageString: "supplyImageURL", description: "Supply Description", sort: "Clothing", quantity: "20", use: "Used", endTime: "2023-11-30", seller: seller, itemType: .supply)
//
//let request = Request(requestID: "456", buyerID: "789", items: [demandProduct, supplyProduct], selectedSellerID: "123", status: .open)
//
//let user = UserData(userID: "789", username: "BuyerName")
