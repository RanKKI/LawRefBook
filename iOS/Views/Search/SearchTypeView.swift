//
//  SearchTypeView.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import SwiftUI

struct SearchTypeView: View {

    @Binding
    var searchType: SearchType

    var body: some View {
        Picker("搜索方式", selection: $searchType) {
            ForEach(SearchType.allCases, id: \.self) {
                Text($0.rawValue)
            }
        }
        .pickerStyle(.segmented)
        .padding([.leading, .trailing], 16)
        .padding(.top, 8)
    }

}
