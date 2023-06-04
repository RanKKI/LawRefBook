//
//  GetProView.swift
//  RefBook
//
//  Created by Hugh Liu on 4/6/2023.
//

import Foundation
import SwiftUI

private var buy_notes = """
一次性付款即可享受到现在和以后所有 Pro 功能。
如果你曾购买过 Pro，请点击**恢复购买**（不会产生任何费用）
"""

struct GetProView: View {

    @ObservedObject
    private var iap = IAPManager.shared
    
    @ObservedObject
    private var preference = Preference.shared
    
    @Environment(\.dismiss)
    private var dismiss

    var body: some View {
        VStack(spacing: 24) {
            HStack(alignment: .firstTextBaseline) {
                Spacer()
                VStack(spacing: 4) {
                    Text("购买 Pro")
                        .bold()
                        .font(.title2)
                    Text("解锁全部功能")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                }
            }
            .padding([.leading, .trailing])
            FeatureCards()
            VStack {
                Button {
                    iap.purchase(item: .Chat_Count) {
                        preference.chatCount += COUNT_EACH_PURCHASE
                    }
                } label: {
                    VStack {
                        if IsProUnlocked {
                            Text("已解锁")
                        } else {
                            Text("立即解锁 (\(iap.getProductPrice(product: .Pro) ?? "..."))")
                        }
                    }
                    .padding([.top, .bottom], 4)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .disabled(IsProUnlocked || iap.isLoading)
                Button {
                    iap.restoreProducts(product: .Pro) {
                        dismiss()
                    }
                } label: {
                    Text("恢复购买")
                        .font(.caption)
                        .underline()
                }
                Divider()
                Text(buy_notes)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("成为 Pro")
        .navigationBarTitleDisplayMode(.inline)

    }
    
}

#if DEBUG
struct GetProView_Previews: PreviewProvider {
    static var previews: some View {
        GetProView()
    }
}
#endif
