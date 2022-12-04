//
//  CoreDataModel.swift
//  RefBook
//
//  Created by Hugh Liu on 2/12/2022.
//

import Foundation
import CoreData

extension FavFolder {

    public var contents: [FavContent] {
        return content?.allObjects as? [FavContent] ?? []
    }

}

extension FavContent {

    static func new(moc: NSManagedObjectContext, _ uuid: UUID, line: Int64, folder: FavFolder) {
        let fav = FavContent(context: moc)
        fav.id = UUID()
        fav.line = line
        fav.lawId = uuid
        fav.folder = folder
        try? moc.save()
    }

}
