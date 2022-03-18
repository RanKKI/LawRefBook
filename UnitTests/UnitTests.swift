import XCTest

@testable import 中国法律

class UnitTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        let laws = LawProvider.shared.lawList
        print(laws)
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
            XCTAssertTrue(!content.Body.isEmpty, "\(uuid) has no content")
        }
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

}
