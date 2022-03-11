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
            if let jsonData = self.readLocalFile(forName: "law", type: "json") {
                self.lawList = try JSONDecoder().decode([LawCategory].self, from: jsonData)
                self.lawList.forEach { category in
                    category.laws.forEach {
                        $0.cateogry = category
                    }
                }
            }
        } catch {
            print("decode error", error)
        }
        return self.lawList
    }

    private func readLocalFile(forName name: String, type: String) -> Data? {
        do {
            if let bundlePath = Bundle.main.path(forResource: name, ofType: type),
               let ret = try String(contentsOfFile: bundlePath).data(using: .utf8) {
                return ret
            }
        } catch {
            print(error)
        }

        return nil
    }

}
