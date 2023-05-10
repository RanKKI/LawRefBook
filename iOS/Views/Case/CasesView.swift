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
        LazyVStack(spacing: 8) {
            ForEach(vm.laws) { law in
                NavigationLink {
                    LawContentView(vm: .init(law: law, searchText: ""))
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    HomeCaseView(law: law)
                }
                .buttonStyle(.plain)
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
            ScrollView {
                CasesView(vm: vm)
                    .padding([.leading, .trailing], 16)
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
