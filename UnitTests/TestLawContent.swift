import XCTest

@testable import 中国法律

class TestLaws: XCTestCase {

    func testParser() async {
        let parser = LawContentParser.shared
        let data = """
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
        """.data(using: .utf8)
        
        XCTAssertNotNil(data)
        guard let data = data else { return }

        let content = parser.parse(data: data)
        XCTAssertNotNil(content)
        guard let content = content else { return }
        
        XCTAssertFalse(content.titles.isEmpty)
        XCTAssertEqual(content.titles.first, "这是一条测试")
        XCTAssertEqual(content.getLine(line: 2), "第二条 内容")
        XCTAssertEqual(content.getLine(line: 3), "副标题2")
        XCTAssertEqual(content.getLine(line: 4), "第三条 内容")

    }

    func testContentTOC() throws {
        let parser = LawContentParser.shared
        let data = """
            # 这是一条测试

            标题1 内容1

            标题2 内容1

            <!-- INFO END -->

            ## 副标题
            第一条 内容

            第二条 内容

            ## 副标题2

            ### 副副标题
            ### 副副标题3
            <!-- FORCE BREAK -->
            第三条 内容
        """.data(using: .utf8)
        
        XCTAssertNotNil(data)
        guard let data = data else { return }

        let content = parser.parse(data: data)
        XCTAssertNotNil(content)
        guard let content = content else { return }

        XCTAssertEqual(content.toc.count, 2)
        XCTAssertEqual(content.toc.first?.title, "副标题")
        XCTAssertEqual(content.toc.first?.line, 0)
        XCTAssertEqual(content.toc.first?.children.count, 0)

        XCTAssertEqual(content.toc.last?.title, "副标题2")
        XCTAssertEqual(content.toc.last?.line, 3)
        
        XCTAssertEqual(content.toc.last?.children.count, 2)
        XCTAssertEqual(content.toc.last?.children.first?.title, "副副标题")
        XCTAssertEqual(content.toc.last?.children.last?.title, "副副标题3")
    }

    func testNoTOC() async {
        let parser = LawContentParser.shared
        let data = """
            # 这是一条测试
            <!-- INFO END -->

            第一条 内容

            第二条 内容
        """.data(using: .utf8)

        XCTAssertNotNil(data)
        guard let data = data else { return }

        let content = parser.parse(data: data)
        XCTAssertNotNil(content)
        guard let content = content else { return }
        
        XCTAssertTrue(content.toc.isEmpty)
    }
    
    func testInfos() async {
        let parser = LawContentParser.shared
        let data = """
            # 这是一条测试
            第一条 内容123

            中间这个没有header

            第二条 内容
            <!-- INFO END -->
            第十条 内容

            第十一条 内容
        """.data(using: .utf8)

        XCTAssertNotNil(data)
        guard let data = data else { return }

        let content = parser.parse(data: data)
        XCTAssertNotNil(content)
        guard let content = content else { return }
        
        XCTAssertEqual(content.info.count, 3)
        XCTAssertEqual(content.info.first?.header, "第一条")
        XCTAssertEqual(content.info.first?.content, "内容123")
        XCTAssertEqual(content.info[1].header, "")
        XCTAssertEqual(content.info[1].content, "中间这个没有header")
        XCTAssertEqual(content.info.last?.content, "内容")
    }
}
