//
//  Preference.swift
//  RefBook
//
//  Created by Hugh Liu on 20/11/2022.
//

import Foundation
import SwiftUI

class Preference: ObservableObject {

    static let shared = Preference()

    @AppStorage("defaultGroupingMethod", store: .standard)
    var groupingMethod = LawGroupingMethod.department

    @AppStorage("defaultSearchHistoryType")
    var searchHistoryType = SearchHistoryType.share

    @AppStorage("font_content")
    var contentFontSize: Int = FontSizeDefault

    @AppStorage("font_tracking")
    var tracking: Double = FontTrackingDefault

    @AppStorage("font_spacing")
    var spacing: Double = FontSpacingDefault

    @AppStorage("font_line_spacing")
    var lineSpacing: Int = FontLineSpacingDefault

    func resetFont() {
        self.contentFontSize = FontSizeDefault
        self.tracking = FontTrackingDefault
        self.spacing = FontSpacingDefault
        self.lineSpacing = FontLineSpacingDefault
    }
}
