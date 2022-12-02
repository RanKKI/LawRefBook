//
//  LawTOC.swift
//  RefBook
//
//  Created by Hugh Liu on 27/11/2022.
//

import Foundation

struct LawToc: Identifiable {
    var id: Int64 { line }

    var title: String
    var indent: Int
    var line: Int64
    var children: [LawToc] = []
}
