import CoreSpotlight
import MobileCoreServices

func addLawContentToSpotlight(lawUUID: UUID) {
    let lawBook = LawProvider.shared.getLawContent(lawUUID)
    lawBook.load()
    for section in lawBook.Body {
        for content in section.children {
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            attributeSet.title = LawProvider.shared.getLawTitleByUUID(lawUUID)
            attributeSet.contentDescription = content.text
            let item = CSSearchableItem(uniqueIdentifier: "\(lawUUID).\(content.line)", domainIdentifier: "xyz.rankki.law-handbook", attributeSet: attributeSet)
            CSSearchableIndex.default().indexSearchableItems([item]) { error in
                if let error = error {
                    print("Indexing error: \(error.localizedDescription)")
                }
            }
        }
    }
}

func removeLawFromSpotlight(lawUUID: UUID, line: Int) {
    CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(lawUUID).\(line)"]) { error in
        if let error = error {
            print("Deindexing error: \(error.localizedDescription)")
        }
    }
}
