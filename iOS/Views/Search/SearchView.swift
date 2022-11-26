//
//  SearchView.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import SwiftUI

struct SearchView: View {
    
    @ObservedObject
    var vm: VM

    var body: some View {
        VStack {
            SearchTypeView(searchType: $vm.searchType)
            Spacer()
        }
    }
    
}
