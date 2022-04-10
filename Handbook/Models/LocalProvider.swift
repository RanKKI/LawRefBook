import Foundation

class LocalProvider: ObservableObject {

    static let shared = LocalProvider()
    
    private var laws: [Law] = []
    private var lawCategories: [LawCategory] = []
    private lazy var lawMap =  [UUID: Law]()

    lazy var ANIT996_LICENSE: String = {
        readLocalFile(forName: "LICENSE", type: "")?.asUTF8String() ?? ""
    }()

    var DATA_FILE_PATH: String? = Bundle.main.path(forResource: "data", ofType: "json", inDirectory: "Laws")

    func getLaw(_ uuid: UUID) -> Law? {
        return lawMap[uuid]
    }

    func getLaws() -> [Law] {
        return self.laws
    }

    func initLawList() {
        if lawCategories.isEmpty {
            readLocalLawCategories()
            parseLaws()
            parseCategories()
            parseLinkedLaws()
            self.lawMap = Dictionary(uniqueKeysWithValues: self.laws.map { ($0.id, $0) })
        }
    }

    func getLawList() -> [LawCategory] {
        if lawCategories.isEmpty {
            self.initLawList()
        }
        return self.lawCategories
    }

    private func readLocalLawCategories() {
        self.lawCategories = readLocalFile(bundlePath: DATA_FILE_PATH)?.decodeJSON([LawCategory].self) ?? []
    }

    private func parseCategories() {
        guard !self.lawCategories.isEmpty else {
            return
        }
        self.lawCategories.forEach { category in
            category.laws.forEach {
                $0.cateogry = category
            }
        }
    }
    
    private func parseLaws() {
        self.laws  = self.lawCategories.flatMap { $0.laws }
    }
    
    /**
        用于找不同法律之间的依赖关系
     */
    private func parseLinkedLaws(){
        let laws = self.lawCategories.flatMap { $0.laws }
        var linkMap = [UUID: [UUID]]()

        for law in laws {
            guard let cateogry = law.cateogry else { continue }
            guard let cateogryLinks = cateogry.links else { continue }
            if var arr = linkMap[law.id] {
                arr.append(contentsOf: cateogryLinks.filter { !arr.contains($0) })
                linkMap[law.id] = arr
            } else {
                linkMap[law.id] = cateogryLinks
            }
        }

        for law in laws {
            guard let links = law.links else { continue }
            links.forEach { id in
                if var arr = linkMap[law.id] {
                    if !arr.contains(id){
                        arr.append(id)
                        linkMap[law.id] = arr
                    }
                } else {
                    linkMap[law.id] = [id]
                }

                if var arr = linkMap[id] {
                    if !arr.contains(law.id){
                        arr.append(law.id)
                        linkMap[id] = arr
                    }
                } else {
                    linkMap[id] = [law.id]
                }
            }
        }

        for (key, arr) in linkMap {
            if let law = getLaw(key) {
                law.links = arr.filter { $0 != law.id }
            }
        }
    }
}
