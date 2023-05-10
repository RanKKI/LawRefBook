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
    private var sheetManager = SheetMananger<Sheets>()

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
        .searchable(text: .constant(""), placement: .navigationBarDrawer(displayMode: .always))
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
        HomeView()
    }
}
#endif
