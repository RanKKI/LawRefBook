//
//  PackageManager.swift
//  RefBook
//
//  Created by Hugh Liu on 26/5/2023.
//

import Foundation

final class PackageManager {
    
    static let shared = PackageManager()
    
    let builtInLawPath = Bundle.main.url(forResource: "laws", withExtension: "zip")!
    
    var buildInLawMeta: IPackageMetadata { MetadataManager.shared.read(path: builtInLawPath.deletingPathExtension())! }
    
    func needUpdate() -> Bool {
        return MetadataManager.shared.needUpdate(meta: buildInLawMeta) ?? true
    }

}
