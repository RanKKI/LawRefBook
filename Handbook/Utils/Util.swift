//
//  Util.swift
//  law.handbook
//
//  Created by HCM-B0208 on 2022/3/1.
//

import Foundation
import SwiftUI
import StoreKit

extension UIApplication {

    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }

}


func OpenMail(subject: String, body: String) {
    let info = String(format: "Version:%@", UIApplication.appVersion ?? "")
    let mailTo = String(format: "mailto:%@?subject=%@&body=%@\n\n%@", DeveloperMail, subject, body, info)
        .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
    let mailtoUrl = URL(string: mailTo!)!
    if UIApplication.shared.canOpenURL(mailtoUrl) {
        UIApplication.shared.open(mailtoUrl, options: [:])
    }
}

func Report(law: LawContent, line: String){
    let subject = String(format: "反馈问题:%@", law.Titles.joined(separator: "-"))
    let body = line
    OpenMail(subject: subject, body: body)
}

extension String {
    static let reviewWorthyActionCount: String  = "reviewWorthyActionCount"
    static let lastReviewRequestAppVersion: String  = "lastReviewRequestAppVersion"
}

enum AppStoreReviewManager {
    static let minimumReviewWorthyActionCount = 3 // 最多可 rate 的次数
    static func requestReviewIfAppropriate() {
        let defaults = UserDefaults.standard
        let bundle = Bundle.main

        var actionCount = defaults.integer(forKey: .reviewWorthyActionCount)

        actionCount += 1

        defaults.set(actionCount, forKey: .reviewWorthyActionCount)

        guard actionCount >= minimumReviewWorthyActionCount else {
            return
        }

        let bundleVersionKey = kCFBundleVersionKey as String
        let currentVersion = bundle.object(forInfoDictionaryKey: bundleVersionKey) as? String
        let lastVersion = defaults.string(forKey: .lastReviewRequestAppVersion)

        guard lastVersion == nil || lastVersion != currentVersion else {
            return
        }

        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
            defaults.set(0, forKey: .reviewWorthyActionCount)
            defaults.set(currentVersion, forKey: .lastReviewRequestAppVersion)
        }
    }
}


extension Array: RawRepresentable where Element: Codable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode([Element].self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}


extension Date {
    static func currentTimestamp() -> Int64 {
        return Int64(Date().timeIntervalSince1970)
    }
}

extension String {
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
    
    func separatedStringWithSeparator(separator: String) -> String {
        return (self.tokenised() as NSArray).componentsJoined(by: (separator))
    }
}


extension String {
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
}

extension Substring {
    public func components(separatedBy separators: [String]) -> [String] {
        return String(self).components(separatedBy: separators)
    }
}

