//
//  CartManager.swift
//  ShareConnect
//
//  Created by laijiaaa1 on 2023/11/18.
//

import Foundation

class CartManager {
    static let shared = CartManager()
    private let userDefaults = UserDefaults.standard
    private let cartKey = "cart"
    private init() {}
    func addToCart(product: Product) {
        var cart = getCart()
        cart[product.seller, default: []].append(product)
        saveCart(cart)
    }
    func convertCartToDictionary(_ cart: [Seller: [Product]]) -> [Seller: [[String: Any]]] {
        var cartDictionary: [Seller: [[String: Any]]] = [:]

        for (seller, products) in cart {
            let productDictionaries = products.map { $0.toDictionary() }
                   cartDictionary[seller] = productDictionaries
        }
        return cartDictionary
    }
    func getCart() -> [Seller: [Product]] {
        do {
            let cartDictionary = userDefaults.object(forKey: cartKey) as? [Seller: [[String: Any]]] ?? [:]
            var convertedCart: [Seller: [Product]] = [:]
            for (seller, productDictionaries) in cartDictionary {
                let products = try productDictionaries.compactMap { try Product(from: $0 as! Decoder) }
                convertedCart[seller] = products
            }
            return convertedCart
        } catch {
            print("Error decoding product: \(error)")
            return [:]
        }
    }
    func saveCart(_ cart: [Seller: [Product]]) {
        let cartDictionary = convertCartToDictionary(cart)
        userDefaults.set(cartDictionary, forKey: cartKey)
    }
}
extension Product {
    func toDictionary() -> [String: Any] {
        return [
            "productId": productId,
            "name": name,
        ]
    }
}
