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

fileprivate struct IAPItemView: View {
    
    var item: Product
    
    @ObservedObject
    var vm = IAPManager.shared

    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                Image(item.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 66)
                if vm.isLoading {
                    ProgressView()
                }
            }
            if let price = vm.getProductPrice(product: item.product) {
                Text(price)
                    .font(.caption)
            } else {
                Image(systemName: "exclamationmark.triangle")
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if let product = vm.getProduct(product: item.product) {
                vm.purchase(product: product)
            }
        }
    }
}

struct InAppPurchaseView: View {
    
    @ObservedObject
    var vm = IAPManager.shared
    
    var body: some View {
        HStack {
            ForEach(Array(products.enumerated()), id: \.offset) { (idx, product) in
                IAPItemView(item: product)
                if idx < products.count - 1 {
                    Spacer()
                }
            }
        }
        .padding([.top, .bottom], 8)
        .padding([.leading, .trailing], 16)
        .task {
            vm.loadProducts()
        }
    }
    
}
