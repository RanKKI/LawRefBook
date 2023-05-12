//
//  HomeView.swift
//  RefBook
//
//  Created by Hugh Liu on 19/3/2023.
//

import Foundation
import SwiftUI

struct HomeView: View {

    @ObservedObject
    private var sheetManager = SheetManager<Sheets>()

    @Environment(\.managedObjectContext)
    private var moc

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
//                HomeBannerView()
                HomeCardView()
                HomeCasesView()
                Spacer()
            }
        }
        .navigationTitle("中国法律")
        .navigationBarTitleDisplayMode(.inline)
    }

}

extension HomeView {

    enum Sheets {
        case favorite
        case setting
    }

}


#if DEBUG
struct HomeView_Preview: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
        .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        .previewDisplayName("iPhone 14")
        NavigationView {
            HomeView()
        }
        .previewDevice(.init(rawValue: "iPad Pro"))
        .previewDisplayName("iPad")
    }
}
#endif
