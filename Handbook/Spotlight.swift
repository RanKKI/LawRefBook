import CoreSpotlight
import MobileCoreServices

class SpotlightHelper {

    static let shared = SpotlightHelper()

    private var queue = DispatchQueue(label: "Spotlight", qos: .background)

    private var spotItems = [
        "宪法",
        "法律",
        "司法解释",
        "行政法规"
    ]

    func createIndexes() {
//        queue.async {
//            let now = Date.currentTimestamp()
//            print("creating spotlight indexes")
//            for law in LawDatabase.shared.getLaws() {
//                if !self.spotItems.contains(law.level) {
//                    continue
//                }
//                let content = LocalProvider.shared.getLawContent(law.id)
//                content.load()
//                self.addLawContentToSpotlight(content: content, law: law)
//            }
//            print("creating spotlight indexes end, cost: \(Date.currentTimestamp() - now)")
//        }
    }

    private func addLawContentToSpotlight(content: LawContent, law : TLaw) {
        let serachableItems = content.Body.flatMap { $0.children }.map { (content: TextContent.Content)-> CSSearchableItem in
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            attributeSet.title = law.name
            attributeSet.contentDescription = content.text
            return CSSearchableItem(uniqueIdentifier: "\(law.id).\(content.line)", domainIdentifier: "xyz.rankki.law-handbook", attributeSet: attributeSet)
        }
        CSSearchableIndex.default().indexSearchableItems(serachableItems) { error in
            if let error = error {
                print("Indexing error: \(error.localizedDescription)")
            }
        }

    }

    private func removeLawFromSpotlight(lawUUID: UUID, line: Int) {
        CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: ["\(lawUUID).\(line)"]) { error in
            if let error = error {
                print("Deindexing error: \(error.localizedDescription)")
            }
        }
    }


}
