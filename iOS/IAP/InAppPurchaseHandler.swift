import StoreKit

var IsProUnlocked: Bool {
    UserDefaults.standard.bool(forKey: PurchaseProduct.Pro.rawValue)
}

// MARK: InAppPurchaseMessages
enum InAppPurchaseMessages: String {
    case purchased = "You payment has been successfully processed."
    case failed = "Failed to process the payment."
}

// MARK: PurchaseProduct
enum PurchaseProduct: String, CaseIterable {
    case Cup_of_Milk = "buy_me_a_coffee_1"
    case Cup_of_Milk_Tea = "buy_me_a_coffee_2"
    case Cup_of_Coffee = "buy_me_a_coffee_3"
    case Pro = "pro_version";
}

class InAppPurchaseHandler: NSObject {
    static let shared = InAppPurchaseHandler()

    fileprivate var productIds = PurchaseProduct.allCases.map(\.rawValue)
    fileprivate var productID = ""
    fileprivate var productsRequest = SKProductsRequest()
    fileprivate var productToPurchase: SKProduct?
    fileprivate var fetchProductcompletion: (([SKProduct]) -> Void)?
    fileprivate var purchaseProductcompletion: ((Bool, String?)->Void)?

    private func canMakePurchases() -> Bool {
        SKPaymentQueue.canMakePayments()
    }
}

// MARK: Public methods
extension InAppPurchaseHandler {
    func purchase(product: SKProduct, completion: @escaping ((Bool, String?)->Void)) {
        purchaseProductcompletion = completion
        productToPurchase = product

        if canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            productID = product.productIdentifier
        } else {
            completion(false, "In app purchases are disabled")
        }
    }
    
    func restore(product: SKProduct, completion: @escaping ((Bool, String?)->Void)) {
        purchaseProductcompletion = completion

        if canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            SKPaymentQueue.default().restoreCompletedTransactions()
        } else {
            completion(false, "In app purchases are disabled")
        }

    }

    func fetchAvailableProducts(completion: @escaping (([SKProduct]) -> Void)) {
        fetchProductcompletion = completion

        if productIds.isEmpty {
            fatalError("Product Ids are not found")
        } else {
            productsRequest = SKProductsRequest(productIdentifiers: Set(productIds))
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
}

// MARK: SKProductsRequestDelegate
extension InAppPurchaseHandler: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func productsRequest (_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        if response.products.count > 0, let completion = fetchProductcompletion {
            completion(response.products)
        } else {
            print("Invalid Product Identifiers: \(response.invalidProductIdentifiers)")
        }
    }

    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .failed:
                print("Product purchase failed")
                SKPaymentQueue.default().finishTransaction(transaction)

                if let completion = purchaseProductcompletion {
                    completion(false, transaction.error?.localizedDescription)
                }
                break
            case .purchased:
                print("Product purchase done")
                SKPaymentQueue.default().finishTransaction(transaction)

                if let completion = purchaseProductcompletion {
                    completion(true, nil)
                }
                break
            default:
                print(transaction.error?.localizedDescription ?? "Something went wrong")
                break
            }
        }
    }
}
