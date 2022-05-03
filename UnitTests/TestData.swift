import XCTest

@testable import 中国法律

class TestData: XCTestCase {

    override func setUp() async throws {
        LawDatabase.shared.connect()
    }
    
    func testLevelExists() throws {
        let con = LawDatabase.shared.getConnection()
        let query = TLaw.table.select(TLaw.level)
            .group(TLaw.level)
        let rows = try con.prepare(query)
        for row in rows {
            XCTAssertNotNil(LawLevel.firstIndex(of: row[TLaw.level]))
        }
    }
    
    func testGetLaws() throws {
        let db = LawDatabase.shared
        let ret = db.getLaws(uuids: [
            UUID.create(str: "f8f4cf756e4b47858e5d74e863d062b5"),
            UUID.create(str: "48c4dfeb80394f02a909d4fadac91e25"),
            UUID.create(str: "ae86450871394cafb1c85e66d2a852d6"),
        ])
        XCTAssertEqual(ret.count, 3)
        XCTAssertEqual(ret[0].name, "民法典 侵权责任编")
        XCTAssertEqual(ret[1].name, "最高人民法院关于适用《民法典》有关担保制度的解释")
        XCTAssertEqual(ret[2].name, "民法典 合同编")

        for law in db.getLaws(category: "经济法") {
            XCTAssertEqual(law.category.name, "经济法")
        }
        
        for law in db.getLaws(level: "宪法") {
            XCTAssertEqual(law.level, "宪法")
        }
    }

}
