//
//  FavoriteContentView.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation
import SwiftUI

struct FavoriteContentView: View {

    @ObservedObject
    var vm: VM

    @State
    private var sharing = false

    var body: some View {
        LoadingView(isLoading: $vm.isLoading) {
            if vm.isEmpty {
                Text("空空如也")
            } else {
                List {
                    ForEach(vm.groupedContents) { group in
                        Section {
                            ForEach(group.contents) { item in
                                FavoriteTextView(law: group.law, item: item)
                            }
                        } header: {
                            HStack {
                                Text(group.law.name)
                                if group.law.expired {
                                    Image(systemName: "exclamationmark.triangle")
                                }
                                Spacer()
                            }
                        }
                    }
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                ShareButton(sharing: $sharing)
            }
        }
        .onAppear {
            vm.onAppear()
        }
        .sheet(isPresented: $sharing) {
            ShareLawView(vm: vm.shareVM)
        }
    }

}

struct FavoriteTextView: View {

    var law: TLaw
    var item: FavoriteContentView.ContentItem

    @Environment(\.managedObjectContext)
    private var moc

    @State
    private var sharing = false

    private var delete: some View {
        Button {
            withAnimation {
                moc.delete(item.data)
                try? moc.save()
            }
        } label: {
            Label("取消收藏", systemImage: "heart.slash")
        }
    }

    var body: some View {
        Text(item.content)
            .swipeActions {
                delete.tint(.red)
            }
            .contextMenu {
                delete
                CopyLawTextButton(law: law, text: item.content)
                ShareButton(sharing: $sharing)
            }
            .sheet(isPresented: $sharing) {
                ShareLawView(vm: .init([.init(name: law.name, content: item.content)]))
            }
    }

}
