//
//  PurchaseManager.swift
//  PhotoRoad
//
//  Created by 워뇨옹 on 6/19/24.
//

import Foundation
import StoreKit
import SwiftyStoreKit

struct PurchaseProperties: Decodable {
    var monthly: String
    var annual: String
    var sharedSecret: String
}

private func getPurchaseProperties() throws -> PurchaseProperties? {
    let plistUrl = Bundle.main.url(forResource: "Purchase", withExtension: "plist")
    guard let plistUrl = plistUrl else {
        return nil
    }

    do {
        let data = try Data(contentsOf: plistUrl)
        let result = try PropertyListDecoder().decode(PurchaseProperties.self, from: data)
        return result
    } catch {
        throw error
    }
}

class PurchaseManager: ObservableObject {
    static let shared: PurchaseManager = PurchaseManager()

    @Published var isPremiumUser: Bool = false
    @Published var subscriptionViewPresent: Bool = false
    @Published var isDebugMode: Bool = false
    var canAccessPremium: Bool {
        isPremiumUser || isDebugMode
    }
    private var purchaseProperties: PurchaseProperties?
    private var products: Set<SKProduct> = []
    
    private init() {
        self.isPremiumUser = UserDefaults.standard.bool(forKey: "isPremium")
        guard let purchaseProperties = try? getPurchaseProperties() else {
            return
        }
        self.purchaseProperties = purchaseProperties
        SwiftyStoreKit.retrieveProductsInfo([purchaseProperties.monthly, purchaseProperties.annual]) { result in
            self.products = result.retrievedProducts
        }
    }

    func purchaseMonthlyPremium(_ completion: @escaping (PurchaseResult) -> Void) {
        guard let purchaseProperties = self.purchaseProperties else {
            completion(.error(error: .init(.unknown)))
            return
        }
        SwiftyStoreKit.purchaseProduct(
            purchaseProperties.monthly,
            quantity: 1,
            atomically: true
        ) { result in
            completion(result)
        }
    }
    func purchaseAnnualPremium(_ completion: @escaping (PurchaseResult) -> Void) {
        guard let purchaseProperties = self.purchaseProperties else {
            completion(.error(error: .init(.unknown)))
            return
        }
        SwiftyStoreKit.purchaseProduct(
            purchaseProperties.annual,
            quantity: 1,
            atomically: true
        ) { result in
            completion(result)
        }
    }

    func restorePremium(_ completion: @escaping (Bool) -> Void) {
        guard let purchaseProperties = self.purchaseProperties else {
            completion(false)
            return
        }
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoredPurchases.count > 0 {
                guard let purchase = results.restoredPurchases.last else {
                    return
                }
                let appleValidator = AppleReceiptValidator(
                    service: .production,
                    sharedSecret: purchaseProperties.sharedSecret
                )
                SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
                    switch result {
                    case .success(receipt: let receipt):
                        let productId = purchase.productId
                        let purchaseResult = SwiftyStoreKit.verifySubscription(
                            ofType: .autoRenewable,
                            productId: productId,
                            inReceipt: receipt
                        )
                        self.setResult(purchaseResult: purchaseResult)
                        completion(self.isPremiumUser)
                    case .error(error: let error):
                        print(error.localizedDescription)
                        completion(false)
                    }
                }
            } else if results.restoreFailedPurchases.count > 0 {
                completion(false)
            } else {
                completion(false)
            }
        }
    }

    func verifySubscription(_ completion: @escaping (VerifySubscriptionResult) -> Void) {
        guard let purchaseProperties = self.purchaseProperties else {
            return
        }
        let appleValidator = AppleReceiptValidator(
            service: .production,
            sharedSecret: purchaseProperties.sharedSecret
        )
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(receipt: let receipt):
                let productId = purchaseProperties.annual
                let purchaseResult = SwiftyStoreKit.verifySubscription(
                    ofType: .autoRenewable,
                    productId: productId,
                    inReceipt: receipt
                )
                self.setResult(purchaseResult: purchaseResult)
                completion(purchaseResult)
            case .error(error: let error):
                print(error.localizedDescription)
            }
        }
    }

    func setUserPremium(as value: Bool) {
        self.isPremiumUser = value
        UserDefaults.standard.set(value, forKey: "isPremium")
    }

    func setResult(purchaseResult: VerifySubscriptionResult) {
        switch purchaseResult {
        case .purchased(let exprDate, _):
#if DEBUG
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "YYYY-MM-dd HH:mm:ss"
            print("[PurchaseManager] purchased you are premium until \(dateFormat.string(from: exprDate))")
#endif
            self.setUserPremium(as: true)
            return
        case .expired:
#if DEBUG
            print("[PurchaseManager] restore expired you are not premium")
#endif
            self.setUserPremium(as: false)
            return
        case .notPurchased:
#if DEBUG
            print("[PurchaseManager] restore not purchased you are not premium")
#endif
            self.setUserPremium(as: false)
            return
        }
    }
    func getMonthlyPrice() -> String? {
        guard let purchaseProperties = self.purchaseProperties else {
            return nil
        }

        for product in self.products where product.productIdentifier == purchaseProperties.monthly {
            return product.localizedPrice
        }
        return nil
    }
    func getAnnualPrice() -> String? {
        guard let purchaseProperties = self.purchaseProperties else {
            return nil
        }

        for product in self.products where product.productIdentifier == purchaseProperties.annual {
            return product.localizedPrice
        }
        return nil
    }
}
