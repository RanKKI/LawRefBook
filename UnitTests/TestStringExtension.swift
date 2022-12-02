import XCTest

@testable import 中国法律

class TestStringExtension: XCTestCase {

    func testCompoents() throws {
        let text = "测试一二三，是个词语，法律，词语，此时"
        XCTAssertEqual(text.components(separatedBy: ["法律"]), ["测试一二三，是个词语，", "法律", "，词语，此时"])
        XCTAssertEqual(text.components(separatedBy: ["法律", "测试"]), ["测试", "一二三，是个词语，", "法律", "，词语，此时"])
        XCTAssertEqual(text.components(separatedBy: ["法律", "测试", "此时"]), ["测试", "一二三，是个词语，", "法律", "，词语，", "此时"])
        XCTAssertEqual(text.components(separatedBy: ["法律", "测试", "此时", "词语"]), ["测试", "一二三，是个", "词语", "，", "法律", "，", "词语", "，", "此时"])
    }

    func testTokenize() throws {
        XCTAssertEqual("法律中国".tokenised(), ["法律", "中国"])
        XCTAssertEqual("法律中国测试".tokenised(), ["法律", "中国", "测试"])
        XCTAssertEqual("法律中国测试".tokenisedString(separator: ","), "法律,中国,测试")
    }

}
