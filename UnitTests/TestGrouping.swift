import XCTest
import SwiftUI

@testable import 中国法律

class TestGrouping: XCTestCase {
        
    
    @AppStorage("defaultGroupingMethod", store: .standard)
    private var groupingMethod = LawGroupingMethod.department
    
    func testAllGroupAreExists() throws {
        let arr = LocalProvider.shared.getLawList().flatMap { $0.laws }
        arr.forEach { law in
            XCTAssertTrue(ArrayLevelSort.firstIndex(of: law.level) != nil, "\(law.level) is not exists")
        }
    }
    
    
    func testGroupingCount() throws {
        groupingMethod = .department
        LawProvider.shared.loadLawList()
        let count1 = LawProvider.shared.lawList.flatMap { $0 }.count
        
        groupingMethod = .level
        LawProvider.shared.loadLawList()
        let count2 = LawProvider.shared.lawList.flatMap { $0 }.count
        
        XCTAssertTrue(count1 == count2, "不同分组方式的法律数量应当是一致的, \(count1) == \(count2)")
    }

}
