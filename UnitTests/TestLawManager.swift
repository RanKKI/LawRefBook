import XCTest

@testable import 中国法律

class TestLawManager: XCTestCase {

    override func setUp() async throws {
        await LawManager.shared.connect()
    }

    func testAllLevelExists() async {
        let laws = await LawManager.shared.getLaws()
        for law in laws {
            XCTAssertNotNil(LawLevel.firstIndex(of: law.level))
        }
    }

    func testGetLaw() async {
        let law = await LawManager.shared.getLaw(id: UUID.create(str: "f8f4cf756e4b47858e5d74e863d062b5"))
        XCTAssertNotNil(law)
        XCTAssertEqual(law?.name, "民法典 侵权责任编")
    }

    func testGetLawsByCategory() async {
        for law in await LawManager.shared.getLaws(category: "经济法") {
            XCTAssertEqual(law.category.name, "经济法")
        }

        for law in await LawManager.shared.getLaws(categoryID: .create(str: "2686206d155643f080cbc60696e53fe5")) {
            XCTAssertEqual(law.category.name, "宪法相关法")
        }
    }

    func testGetLaws() async {
        let laws = await LawManager.shared.getLaws(ids: [
            UUID.create(str: "f8f4cf756e4b47858e5d74e863d062b5"),
            UUID.create(str: "48c4dfeb80394f02a909d4fadac91e25"),
            UUID.create(str: "ae86450871394cafb1c85e66d2a852d6")
        ])
        let expectedLaws = ["民法典 侵权责任编", "最高人民法院关于适用《民法典》有关担保制度的解释", "民法典 合同编"]
        XCTAssertEqual(laws.count, 3)
        for law in laws {
            XCTAssertTrue(expectedLaws.contains(law.name))
        }
    }

    func testGetCategories() async {
        for cateogry in await LawManager.shared.getCategories(by: .level) {
            XCTAssertTrue(LawLevel.contains(cateogry.name))
        }
    }

    func testAllLawContentAreCorrect() async {
        for law in await LawManager.shared.getLaws() {
            let db = LawManager.shared.getDatabaseByLaw(law: law)
            XCTAssertNotNil(db)
            let path = db?.getLawLocalFilePath(law: law)
            XCTAssertNotNil(path)
            guard let path = path else { continue }

            // 确保文件存在
            XCTAssertTrue(path.isExists())

            let content = await LawContentManager.shared.read(law: law)
            // 确保内容存在
            XCTAssertNotNil(content)
            guard let content = content else { continue }

            // 所有法律法规应当有一个标题，并且内容不能为空
            XCTAssertFalse(content.titles.isEmpty)
            XCTAssertFalse(content.sections.isEmpty)

            // TOC 不应该有相同的 title
            let dict = Dictionary(grouping: content.toc, by: \.title)
            dict.forEach { (key, val) in
                XCTAssertEqual(val.count, 1, "\(law.name) 多个一样的标题 \(key)")
            }
        }
    }

}
