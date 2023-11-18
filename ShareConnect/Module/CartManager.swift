import Foundation
////
////  CartManager.swift
////  ShareConnect
////
////  Created by laijiaaa1 on 2023/11/18.
////
//
//import Foundation
//
//class CartManager {
//    static let shared = CartManager()
//    private let userDefaults = UserDefaults.standard
//    private let cartKey = "cart"
//
//    private init() {}
//
//    func addToCart(product: Product) {
//        var cart = getCart()
//        cart[product.seller, default: []].append(product)
//        saveCart(cart)
//    }
//
//    func convertCartToDictionary(_ cart: [Seller: [Product]]) -> [Seller: [[String: Any]]] {
//        var cartDictionary: [Seller: [[String: Any]]] = [:]
//
//        for (seller, products) in cart {
//            let productDictionaries = products.map { $0.toDictionary() }
//            cartDictionary[seller] = productDictionaries
//        }
//
//        return cartDictionary
//    }
//
//    func getCart() -> [Seller: [Product]] {
//           let cartDictionary = userDefaults.object(forKey: cartKey) as? [Seller: [[String: Any]]] ?? [:]
//
//           var convertedCart: [Seller: [Product]] = [:]
//
//           for (seller, productDictionaries) in cartDictionary {
//               let products = productDictionaries.compactMap { Product(from: $0) }
//               convertedCart[seller] = products
//           }
//
//           return convertedCart
//       }
//
//    func saveCart(_ cart: [Seller: [Product]]) {
//        let cartDictionary = convertCartToDictionary(cart)
//        userDefaults.set(cartDictionary, forKey: cartKey)
//    }
//
//}

