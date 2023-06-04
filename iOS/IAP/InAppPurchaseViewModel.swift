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

    func isPurcahsed(product: PurchaseProduct) -> Bool {
        return UserDefaults.standard.bool(forKey: product.rawValue)
    }
    
    func refreshPurchased() {
        let arr: [PurchaseProduct] = [.Chat_Monthly_Sub]
        arr.forEach { product in
            self.restoreProducts(product: product) {
                print("restore \(product) success ")
            }
        }
    }

    func restoreProducts(product: PurchaseProduct, success: @escaping ()->Void) {
        guard let pd = getProduct(product: product) else {
            return
        }
        self.isLoading = true
        print("Restoring products ...")
        InAppPurchaseHandler.shared.restore(product: pd) { flag, log in
            if flag {
                UserDefaults.standard.set(true, forKey: product.rawValue)
                success()
            }
            if let log = log {
                print("InAppPurchaseHandler purchase \(log)")
            }
            self.isLoading = false
        }
    }

    func loadProducts() {
        guard !isLoading else { return }
        guard products.isEmpty else { return }
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

    func purchase(item: PurchaseProduct, success: @escaping (()->Void)) {
        guard let product = getProduct(product: item) else {
            return
        }
        self.purchase(product: product, success: success)
    }

    func purchase(product: SKProduct, success: @escaping (()->Void)) {
        let now = Date.currentTimestamp()
        if now - lastPurchaseTime < 2 {
            return
        }
        lastPurchaseTime = now
        self.isLoading = true
        InAppPurchaseHandler.shared.purchase(product: product) { _, _ in
            self.isLoading = false
            success()
        }
    }
}
