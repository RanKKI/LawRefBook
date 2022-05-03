import Foundation
import SwiftUI

private struct Product: Identifiable {
    var id = UUID()
    
    var product: PurchaseProduct
    var icon: String
    var price: String
}

private let products = [
    Product(product: .Cup_of_Milk, icon: "milk", price: "6.00 CNY"),
    Product(product: .Cup_of_Milk_Tea, icon: "beer", price: "12.00 CNY"),
    Product(product: .Cup_of_Coffee, icon: "coffee", price: "18.00 CNY")
]

struct InAppPurchaseView: View {
    
    @ObservedObject
    var vm: ViewModel
    
    var body: some View {
        VStack {
            if vm.isLoading {
                Spacer()
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                Spacer()
            } else {
                HStack {
                    ForEach(Array(products.enumerated()), id: \.offset) { (idx, product) in
                        VStack {
                            Image(product.icon)
                                .resizable()
                                .frame(width: 48, height: 48)
                            Text(product.price)
                                .font(.caption)
                        }
                        if idx < products.count - 1 {
                            Spacer()
                        }
                    }
                }
                .padding([.top, .bottom], 8)
                .padding([.leading, .trailing], 16)
            }
        }
        .onAppear {
            vm.loadProducts()
        }
    }
    
}
