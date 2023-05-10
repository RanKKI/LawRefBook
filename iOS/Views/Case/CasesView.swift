//
//  CaseListView.swift
//  RefBook
//
//  Created by Hugh Liu on 9/5/2023.
//

import Foundation
import SwiftUI

struct CasesView: View {

    @ObservedObject
    var vm: VM

    var body: some View {
        VStack(spacing: 8) {
            ForEach(vm.laws) { law in
                HomeCaseView(law: law)
            }
        }
        .onAppear {
            vm.load()
        }
    }
}

extension CasesView {
    
    struct ListType: View {
        
        @ObservedObject
        var vm: VM
        
        var body: some View {
            List {
                ForEach(vm.laws) { law in
                    HomeCaseView(law: law)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 8))
                }
            }
            .listStyle(.plain)
            .onAppear {
                vm.load()
            }
        }
        
    }
    
}

struct HomeCaseView: View {
    
    let law: TLaw
    @State
    private var availableWidth: CGFloat = 10
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(law.name)
                .lineLimit(2)
                .font(.system(size: 13))
            
            FlexibleView(data: law.tagArray.prefix(4), vSpacing: 4, hSpacing: 8, maxLine: 1) { tagName in
                HomeCaseTagView(text: tagName)
            }

        }
        .padding(8)
        .modifier(HomeCardEffect())
    }
    
}

private struct HomeCaseTagView: View {
    
    var text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .fontWeight(.light)
            .padding([.leading, .trailing], 8)
            .padding([.top, .bottom], 2)
            .background {
                RoundedRectangle(cornerRadius: 4)
                    .fill(.gray.opacity(0.2))
            }
    }
    
}
