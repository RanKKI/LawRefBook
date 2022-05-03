import StoreKit

extension InAppPurchaseView {
    
    class ViewModel: ObservableObject {
        
        @Published
        var products = [SKProduct]()
        
        @Published
        var isLoading = false
        
        fileprivate var queue = DispatchQueue(label: "IAP", qos: .background)
        
        func loadProducts() {
            isLoading = true
            queue.async {
                InAppPurchaseHandler.shared.fetchAvailableProducts { products in
                    DispatchQueue.main.async {
                        self.isLoading = false
                        self.products = products
                        print(products)
                    }
                }
            }
        }
    }
    
}
