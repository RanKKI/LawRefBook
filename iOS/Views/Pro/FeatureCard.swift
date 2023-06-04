//
//  FeatureCard.swift
//  RefBook
//
//  Created by Hugh Liu on 4/6/2023.
//

import Foundation
import SwiftUI

struct ProItem: Identifiable {
    var id = UUID()
    var icon: String
    var title: String
}

var proItems = [
    ProItem(icon: "captions.bubble", title: "无限次数使用 AI 法律助手"),
    ProItem(icon: "square.and.arrow.down.on.square", title: "地方性法规内容补充包"),
    ProItem(icon: "ellipsis", title: "还有一些正在开发中的功能")
]

var freeItems = [
    ProItem(icon: "text.book.closed", title: "3000+部现行法律法规"),
    ProItem(icon: "book", title: "经典司法案例、司法解释"),
    ProItem(icon: "icloud", title: "跨设备同步、法律法条的收藏"),
    ProItem(icon: "magnifyingglass", title: "全文搜索"),
]

struct FeatureCards: View {
    
    var body: some View {
        VStack {
            FeatureCard(label: "Pro 功能", items: proItems)
            FeatureCard(label: "免费版功能", items: freeItems)
        }
    }
    
}

struct FeatureCard: View {

    var label: String
    var items: [ProItem]

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "list.and.film")
                    .foregroundColor(.clear)
                    .frame(width: 36)
                Text(label)
                    .bold()
                    .font(.title3)
                Spacer()
            }
            ForEach(items) { item in
                HStack(alignment: .firstTextBaseline) {
                    Image(systemName: item.icon)
                        .frame(width: 36)
                    Text(item.title)
                    Spacer()
                }
            }
        }
        .padding([.all], 32)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .padding([.all], 8)
                .foregroundColor(.gray.opacity(0.1))
        }
    }

}

#if DEBUG
struct FeatureCards_Previews: PreviewProvider {
    static var previews: some View {
        FeatureCards()
    }
}
#endif
