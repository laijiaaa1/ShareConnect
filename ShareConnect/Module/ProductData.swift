//
//  ProductData.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/12/22.
//

import Foundation
import FirebaseFirestore

struct Product: Codable, Equatable {
    var productId: String
    var name: String
    var price: String
    var startTime: String
    var imageString: String
    var description: String
    var sort: String
    var quantity: Int = 1
    var use: String
    var endTime: String
    var seller: Seller
    var itemType: ProductType
    var isCollected: Bool = false
    enum CodingKeys: String, CodingKey {
        case productId, name, price, startTime, imageString, description, sort, quantity, use, endTime, seller, itemType
    }
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.productId == rhs.productId
    }
    init(productId: String,
         name: String,
         price: String,
         startTime: String,
         imageString: String,
         description: String,
         sort: String,
         quantity: Int,
         use: String,
         endTime: String,
         seller: Seller,
         itemType: ProductType) {
        self.productId = productId
        self.name = name
        self.price = price
        self.startTime = startTime
        self.imageString = imageString
        self.description = description
        self.sort = sort
        self.quantity = quantity
        self.use = use
        self.endTime = endTime
        self.seller = seller
        self.itemType = itemType
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productId = try container.decode(String.self, forKey: .productId)
        name = try container.decode(String.self, forKey: .name)
        price = try container.decode(String.self, forKey: .price)
        startTime = try container.decode(String.self, forKey: .startTime)
        imageString = try container.decode(String.self, forKey: .imageString)
        description = try container.decode(String.self, forKey: .description)
        sort = try container.decode(String.self, forKey: .sort)
        quantity = try container.decode(Int.self, forKey: .quantity)
        use = try container.decode(String.self, forKey: .use)
        endTime = try container.decode(String.self, forKey: .endTime)
        seller = try container.decode(Seller.self, forKey: .seller)
        itemType = try container.decode(ProductType.self, forKey: .itemType)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(productId, forKey: .productId)
        try container.encode(name, forKey: .name)
        try container.encode(price, forKey: .price)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(imageString, forKey: .imageString)
        try container.encode(description, forKey: .description)
        try container.encode(sort, forKey: .sort)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(use, forKey: .use)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(seller, forKey: .seller)
        try container.encode(itemType, forKey: .itemType)
    }
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
    enum CodingKeys: String, CodingKey {
        case sellerID, sellerName
    }
    init(sellerID: String, sellerName: String) {
        self.sellerID = sellerID
        self.sellerName = sellerName
    }
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        sellerID = try container.decode(String.self, forKey: .sellerID)
        sellerName = try container.decode(String.self, forKey: .sellerName)
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sellerID, forKey: .sellerID)
        try container.encode(sellerName, forKey: .sellerName)
    }
}
