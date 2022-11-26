//
//  LawListFoldersView.swift
//  RefBook
//
//  Created by Hugh Liu on 21/11/2022.
//

import Foundation
import SwiftUI

struct LawListFoldersView: View {

    @Binding
    var folders: [[TCategory]]

    var body: some View {
        ForEach(folders, id: \.self) { folderArr in
            Section {
                ForEach(folderArr) {
                    LawListSubFolderView(category: $0)
                }
            } header: {
                Text(folderArr.first?.group ?? "")
            }
        }
    }

}
