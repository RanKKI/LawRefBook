//
//  FavoriteVieww.swift
//  RefBook
//
//  Created by Hugh Liu on 1/12/2022.
//

import Foundation
import SwiftUI

struct FavoriteFolderSelectionView: View {

    @FetchRequest(sortDescriptors: [
        SortDescriptor(\.order)
    ], predicate: nil)
    private var folders: FetchedResults<FavFolder>

    @Environment(\.dismiss)
    private var dismiss
    
    var action: (FavFolder?) -> Void

    var body: some View {
        NavigationView {
            List {
                ForEach(folders) { folder in
                    Text(folder.name ?? "")
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismiss()
                            action(folder)
                        }
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing){
                    FavoriteFolderCreateButton()
                    CloseSheetItem() {
                        dismiss()
                        action(nil)
                    }
                }
            }
            .phoneOnlyStackNavigationView()
            .navigationTitle("选择文件夹")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
}
