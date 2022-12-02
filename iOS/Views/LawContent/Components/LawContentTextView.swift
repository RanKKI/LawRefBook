//
//  LawContentTextView.swift
//  RefBook
//
//  Created by Hugh Liu on 27/11/2022.
//

import Foundation
import SwiftUI

struct LawContentTextView: View {

    var text: String
    var searchText: String

    @Environment(\.colorScheme)
    private var colorScheme

    private var preference = Preference.shared

    init(text: String) {
        self.text = text
        self.searchText = ""
    }

    func highlightText(_ str: Substring) -> Text {
        guard !str.isEmpty && !searchText.isEmpty else { return Text(str) }

        var highlightTexts = searchText.tokenised()
        if !highlightTexts.contains(searchText) {
            highlightTexts.append(searchText)
        }
        var result: Text!
        let parts = str.components(separatedBy: highlightTexts)
        for part in parts {
            let isKeyword = highlightTexts.contains(part)
            var text = Text(part)
            if isKeyword {
                text = text.highlight(size: CGFloat(preference.contentFontSize + 2))
            }
            result = result == nil ? text : (result + text)
        }
        return result ?? Text(str)
    }

    var body: some View {
        Group {
            let arr = text.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            if arr.count == 1 || arr[0].range(of: lineStartRe, options: .regularExpression) == nil {
                let range = text.startIndex..<text.endIndex
                highlightText(text[range])
            } else {
                (Text(arr[0]).bold() + Text(" ") + highlightText(arr[1]))
            }
        }
        .font(.system(size: CGFloat(preference.contentFontSize)))
//        .tracking(preference.tracking)
        .lineSpacing(preference.spacing)
        .padding(EdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4))
        .background(colorScheme == .dark ? Color.clear : Color.white)
    }

}
