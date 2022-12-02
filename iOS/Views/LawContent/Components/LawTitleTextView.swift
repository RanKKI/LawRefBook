//
//  LawTitle.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import SwiftUI

struct LawTitleTextView: View {

    var titles: [String]

    var body: some View {
        ForEach(titles, id: \.self) {
            Text($0).displayMode(.Title)
        }
    }

}
