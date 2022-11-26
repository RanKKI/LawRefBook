//
//  String.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation

extension String {

    static let reviewWorthyActionCount: String  = "reviewWorthyActionCount"
    static let lastReviewRequestAppVersion: String  = "lastReviewRequestAppVersion"

    func tokenised() -> [String] {
        let locale = CFLocaleCopyCurrent()
        let range = CFRangeMake(0, CFStringGetLength(self as CFString))
        let tokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, self as CFString, range, UInt(kCFStringTokenizerUnitWordBoundary), locale)

        var tokens = [String]()
        var tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)


        while (tokenType != []) {
            let range = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            let token = CFStringCreateWithSubstring(kCFAllocatorDefault, self as CFString, range)
            if let token = token {
                tokens.append(token as String)
            }
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }

        return tokens
    }

    func tokenisedString(separator: String) -> String {
        return (self.tokenised() as NSArray).componentsJoined(by: (separator))
    }
    
    public func components(separatedBy separators: [String]) -> [String] {
        var output: [String] = [self]
        for separator in separators {
            output = output.flatMap {
                $0.components(separatedBy:  separator) // first split
                                        .flatMap { [$0, separator] } // add the separator after each split
                                        .dropLast() // remove the last separator added
                                        .filter { $0 != "" } // remove empty strings
            }
        }
        return output
    }
    
    func toTableData() -> TableData {
        var ret = [[String]]()
        for subtext in self.split(separator: "\n") {
            if subtext.starts(with: "|-") {
                /* Markdown 的分隔符，无意义*/
                continue
            }
            if !subtext.starts(with: "|") {
                /* 可能是注释，无意义*/
                continue
            }
            ret.append(subtext.components(separatedBy: "|").filter { !$0.isEmpty }.map {$0.trimmingCharacters(in: .whitespacesAndNewlines)})
        }
        return ret
    }

}

extension Substring {
    
    public func components(separatedBy separators: [String]) -> [String] {
        return String(self).components(separatedBy: separators)
    }
    
}
