import XCTest

@testable import 中国法律

class TestRegularExp: XCTestCase {
    
    func testLineStartReg() throws {
        XCTAssertNotNil("第一条 测试，123".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNotNil("第一二条 测试，123".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNotNil("第一二三条 测试，123".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNotNil("第十零三条 测试，123".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNotNil("一、测试，123".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNotNil("一二、测试，123".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNotNil("一二零、测试，123".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNotNil("一二零十、测试，123".range(of: lineStartRe, options: .regularExpression))
        
        XCTAssertNil("一二零十册、测试，123".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNil("5⃣️、测试，123".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNil("48、测试，123".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNil("48、测试，123".range(of: lineStartRe, options: .regularExpression))
        
        XCTAssertNil("第7条测试，123".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNil("第8⃣️条测试，123".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNil("第8⃣️条 测试，123".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNil("第叁条 测试，123".range(of: lineStartRe, options: .regularExpression))
        
        XCTAssertNil("测试在中间的第三条".range(of: lineStartRe, options: .regularExpression))
        XCTAssertNil("测试在中间的三、".range(of: lineStartRe, options: .regularExpression))
    }
    
}
