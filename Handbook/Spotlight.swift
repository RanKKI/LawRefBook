import CoreSpotlight
import MobileCoreServices

class SpotlightHelper: ObservableObject {
    static let shared = SpotlightHelper()
    
    @Published
    var isLoading = false
    
    private var queue = DispatchQueue(label: "laws", qos: .background)
    
    func createIndexs() {
        queue.async {
            DispatchQueue.main.async {
                self.isLoading = true
            }
            for law in LocalProvider.shared.getLaws() {
                let content = LawProvider.shared.getLawContent(law.id)
                content.load()
                self.addLawContentToSpotlight(content: content, uuid: law.id)
            }
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }
    }
    
    private func addLawContentToSpotlight(content: LawContent, uuid: UUID) {
        let serachableItems = content.Body.flatMap { $0.children }.map { (content: TextContent.Content)-> CSSearchableItem in
            let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
            attributeSet.title = LawProvider.shared.getLawTitleByUUID(uuid)
            attributeSet.contentDescription = content.text
            return CSSearchableItem(uniqueIdentifier: "\(uuid).\(content.line)", domainIdentifier: "xyz.rankki.law-handbook", attributeSet: attributeSet)
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
