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

private struct IAPItemView: View {

    var item: Product

    @ObservedObject
    var vm = IAPManager.shared

    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                Image(item.icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 55, height: 55)
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

    @State
    private var showSafari = false

    var body: some View {
        Section {
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
        } header: {
            Text("请开发者喝点什么")
        } footer: {
            VStack(alignment: .leading, spacing: 8) {
                Text("如果你觉得这个 App 做得还不错，对你有所帮助的话，请开发者喝点什么吧。")
                Text("Bubble tea icons created by Freepik - Flaticon")
                    .underline()
                    .onTapGesture {
                        showSafari.toggle()
                    }
            }
        }
        .task {
            vm.loadProducts()
        }
        .fullScreenCover(isPresented: $showSafari, content: {
            SFSafariViewWrapper(url: URL(string: "https://www.flaticon.com/free-icons/bubble-tea")!)
        })
    }

}
