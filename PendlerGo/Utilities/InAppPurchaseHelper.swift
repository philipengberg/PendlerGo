//
//  InAppPurchaseHelper.swift
//  PendlerGo
//
//  Created by Philip Engberg on 28/02/2018.
//

import Foundation
import StoreKit
import RxSwift

class InAppPurchaseHelper: NSObject {
    
    enum IAPProduct: String {
        case removeAdsYearly = "com.simplesense.pendlergo.RemoveAdsYearly"
    }
    
    public typealias ProductIdentifier = String
    
    private let requestProductsSubject = PublishSubject<[SKProduct]>()
    private let buyProductSubject = PublishSubject<ProductIdentifier>()
    
    private let productIdentifiers: Set<ProductIdentifier>
    private var purchasedProductIdentifiers = Set<ProductIdentifier>()
    private var productsRequest: SKProductsRequest?
    
    public init(productIds: Set<ProductIdentifier>) {
        productIdentifiers = productIds
        
        for productIdentifier in productIds {
            let purchased = UserDefaults.standard.bool(forKey: productIdentifier)
            if purchased {
                purchasedProductIdentifiers.insert(productIdentifier)
                print("Previously purchased: \(productIdentifier)")
            } else {
                print("Not purchased: \(productIdentifier)")
            }
        }
        super.init()
        
        SKPaymentQueue.default().add(self)
    }
}

// MARK: - StoreKit API

extension InAppPurchaseHelper {
    
    func requestProducts() -> Observable<[SKProduct]> {
        productsRequest?.cancel()
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest?.delegate = self
        productsRequest?.start()
        
        return requestProductsSubject.asObservable()
    }
    
    func buyProduct(_ product: SKProduct) -> Observable<ProductIdentifier> {
        print("Buying \(product.productIdentifier)...")
        SKPaymentQueue.default().add(SKPayment(product: product))
        return buyProductSubject.asObservable()
    }
    
    func isProductPurchased(for product: IAPProduct) -> Bool {
        return purchasedProductIdentifiers.contains(product.rawValue)
    }
    
    class func canMakePayments() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
}

extension InAppPurchaseHelper: SKProductsRequestDelegate {
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        print("Loaded list of products...")
        requestProductsSubject.onNext(response.products)
        
        for p in response.products {
            print("Found product: \(p.productIdentifier) \(p.localizedTitle) \(p.price.floatValue)")
        }
    }
    
    func request(_ request: SKRequest, didFailWithError error: Error) {
        requestProductsSubject.onError(error)
    }
}

extension InAppPurchaseHelper: SKPaymentTransactionObserver {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch (transaction.transactionState) {
            case .purchased: complete(transaction: transaction)
            case .failed: fail(transaction: transaction)
            case .restored: restore(transaction: transaction)
            case .deferred: break
            case .purchasing: break
            }
        }
    }
    
    private func complete(transaction: SKPaymentTransaction) {
        print("Purchase complete...")
        registerPayment(for: transaction.payment.productIdentifier)
        buyProductSubject.onNext(transaction.payment.productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restore(transaction: SKPaymentTransaction) {
        guard let productIdentifier = transaction.original?.payment.productIdentifier else { return }
        
        print("Purchase restored... \(productIdentifier)")
        registerPayment(for: productIdentifier)
        buyProductSubject.onNext(productIdentifier)
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func fail(transaction: SKPaymentTransaction) {
        print("Purchase failed...")
        if let transactionError = transaction.error as? SKError, transactionError.code != SKError.paymentCancelled {
            buyProductSubject.onError(transaction.error!)
        }
        
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func registerPayment(for identifier: String) {
        
        purchasedProductIdentifiers.insert(identifier)
        UserDefaults.standard.set(true, forKey: identifier)
        UserDefaults.standard.synchronize()
    }
}
