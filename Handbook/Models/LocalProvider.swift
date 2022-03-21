import Foundation

class LocalProvider {

    static let shared = LocalProvider()

    private var lawList: [LawCategory] = []
    lazy var lawMap: [UUID: Law] = {
        var ret = [UUID: Law]()
        self.getLawList().flatMap { $0.laws }.forEach {
            ret[$0.id] = $0
        }
        return ret
    }()

    lazy var ANIT996_LICENSE: String = {
        if let data = self.readLocalFile(forName: "LICENSE", type: "") {
            return String(decoding: data, as: UTF8.self)
        }
        return ""
    }()

    func getLaw(_ uuid: UUID) -> Law? {
        return lawMap[uuid]
    }

    func getLawList() -> [LawCategory] {
        if !lawList.isEmpty {
            return self.lawList
        }
        do {
            if let jsonData = self.readLocalFile(forName: "law", type: "json", inDirectory: "法律法规") {
                self.lawList = try JSONDecoder().decode([LawCategory].self, from: jsonData)
                self.lawList.forEach { category in
                    category.laws.forEach {
                        $0.cateogry = category
                    }
                }
                self.analyzeLinks()
            }
        } catch {
            print("decode error", error)
        }
        return self.lawList
    }

    private func analyzeLinks(){
        let laws = self.lawList.flatMap { $0.laws }
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

    private func readLocalFile(forName name: String, type: String, inDirectory: String? = nil) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: type, inDirectory: inDirectory),
               let ret = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return ret
            }
        } catch {
            print(error)
        }

        return nil
    }

}
