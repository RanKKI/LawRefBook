enum Favorite {
    
    static func convert<S>(_ result: S) -> [[FavContent]] where S: Sequence, S.Element == FavContent {
//        return Dictionary(grouping: result) { $0.lawId! }
//            .sorted {
//                let id1 = $0.value.first!.lawId!
//                let id2 = $1.value.first!.lawId!
//                let laws: [TLaw] = LawDatabase.shared.getLaws(uuids: [id1, id2])
//                return laws[0].name < laws[1].name
//            }
//            .map { $0.value }
//            .map { $0.filter{ $0.line > 0 }.sorted { $0.line < $1.line } }
        return []
    }

}
