import StoreKit

class IAPManager: ObservableObject {
    
    static var shared = IAPManager()
    
    @Published
    var products = [SKProduct]()
    
    @Published
    var isLoading = false
    
    var lastPurchaseTime: Int64 = 0
    
    fileprivate var queue = DispatchQueue(label: "IAP", qos: .background)
    
    func getProduct(product: PurchaseProduct) -> SKProduct? {
        return products.first(where: {
            $0.productIdentifier == product.rawValue
        })
    }
    
    func getProductPrice(product: PurchaseProduct) -> String? {
        if let skproduct = getProduct(product: product) {
            return "\(skproduct.priceLocale.currencySymbol ?? "")\(skproduct.price) \(skproduct.priceLocale.currencyCode ?? "")"
        }
        return nil
    }
    
    func loadProducts() {
        isLoading = true
        queue.async {
            InAppPurchaseHandler.shared.fetchAvailableProducts { products in
                DispatchQueue.main.async {
                    self.products = products
                    self.isLoading = false
                }
            }
        }
    }

    func purchase(product: SKProduct) {
        let now = Date.currentTimestamp()
        if now - lastPurchaseTime < 2 {
            return
        }
        lastPurchaseTime = now
        self.isLoading = true
        InAppPurchaseHandler.shared.purchase(product: product) { log, product, transition in
            print("InAppPurchaseHandler purchase \(log)")
            self.isLoading = false
        }
    }

}
