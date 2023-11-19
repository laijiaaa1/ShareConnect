//
//  Data.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/18.
//

import Foundation

struct Product: Codable {
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

enum ProductType: String, Codable {
    case request
    case supply
}
extension ProductType {
    init?(rawValue: String) {
        switch rawValue {
        case "request": self = .request
        case "supply": self = .supply
        default: return nil
        }
    }
}

struct Seller: Hashable, Codable {
    var sellerID: String
    var sellerName: String
}
extension Seller {
    init?(data: [String: Any]) {
        guard
            let sellerID = data["sellerID"] as? String,
            let sellerName = data["sellerName"] as? String
        else {
            return nil
        }

        self.sellerID = sellerID
        self.sellerName = sellerName
    }
}

struct Request: Codable {
    let requestID: String
    let buyerID: String
    let items: [Product]
    let selectedSellerID: String?
    let status: RequestStatus
}

enum RequestStatus: String, Codable {
    case open
    case closed

    init?(rawValue: String) {
        switch rawValue {
        case "open":
            self = .open
        case "closed":
            self = .closed
        default:
            return nil
        }
    }
}

protocol TrolleyCellDelegate: AnyObject {
    func didSelectSeller(sellerID: String)
}

struct UserData: Codable {
    var userID: String
    var username: String
}
