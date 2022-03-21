import XCTest

@testable import 中国法律

class TestLaws: XCTestCase {

    func testContentPaser() throws {
        let str = """
            # 这是一条测试

            标题1 内容1

            标题2 内容1

            <!-- INFO END -->

            ## 副标题
            第一条 内容

            第二条 内容

            ## 副标题2
            <!-- FORCE BREAK -->
            第三条 内容
        """

        let content = LawContent("", "")
        content.loadFromString(content: str)

        XCTAssertTrue(!content.Titles.isEmpty)
        XCTAssertEqual(content.Titles.first!, "这是一条测试")
        XCTAssertEqual(content.getLine(line: 2), "第二条 内容")
        XCTAssertEqual(content.getLine(line: 3), "副标题2")
        XCTAssertEqual(content.getLine(line: 4), "第三条 内容")
    }

    func testContentTOC() throws {
        let str = """
            # 这是一条测试

            标题1 内容1

            标题2 内容1

            <!-- INFO END -->

            ## 副标题
            第一条 内容

            第二条 内容

            ## 副标题2
            ### 节点123
            <!-- FORCE BREAK -->
            第三条 内容
        """

        let content = LawContent("", "")
        content.loadFromString(content: str)

        XCTAssertEqual(content.TOC.count, 2)
        XCTAssertEqual(content.TOC.first!.title, "副标题")
        XCTAssertEqual(content.TOC.first!.line, 0)
        XCTAssertEqual(content.TOC.last!.line, 3)
        XCTAssertEqual(content.TOC.last!.children.count, 1)
        XCTAssertEqual(content.TOC.last!.children.first?.title, "节点123")
    }

    func testAllFileExist() throws {
        let laws = LawProvider.shared.lawList
        let arr = laws.flatMap { $0 }
        for uuid in arr {
            let content = LawProvider.shared.getLawContent(uuid)
            XCTAssertTrue(content.isExists())
        }
    }

    func testAllFileHasContent() throws {
        let laws = LawProvider.shared.lawList
        let arr = laws.flatMap { $0 }
        for uuid in arr {
            let content = LawProvider.shared.getLawContent(uuid)
            content.load()
            XCTAssertTrue(!content.Body.isEmpty, "\(LawProvider.shared.getLawNameByUUID(uuid)) has no content")
        }
    }

    func testAllFileHasTitlte() throws {
        let laws = LawProvider.shared.lawList
        let arr = laws.flatMap { $0 }
        for uuid in arr {
            let content = LawProvider.shared.getLawContent(uuid)
            content.load()
            XCTAssertTrue(!content.Titles.isEmpty, "\(LawProvider.shared.getLawNameByUUID(uuid)) has no title")
        }
    }

    func testJSONFileExists() throws {
        XCTAssertTrue(!LawProvider.shared.lawList.isEmpty, "没有找到任何法律法规！")
    }

}
