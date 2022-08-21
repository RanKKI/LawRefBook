import Foundation
import SwiftUI
import StoreKit
import UIKit
import CoreData

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

func Report(law: TLaw, content: String){
    let subject = String(format: "反馈问题:%@", law.name)
    OpenMail(subject: subject, body: content)
}

extension String {
    static let reviewWorthyActionCount: String  = "reviewWorthyActionCount"
    static let lastReviewRequestAppVersion: String  = "lastReviewRequestAppVersion"
}

enum AppStoreReviewManager {
    static func requestReviewIfAppropriate() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            print("requestReviewIfAppropriate")
            SKStoreReviewController.requestReview(in: scene)
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

    func tokenisedString(separator: String) -> String {
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

extension View {

    func shareText(_ shareString: String) {
        if let controller = topMostViewController() {
            let activityViewController = UIActivityViewController(activityItems: [shareString], applicationActivities: nil);
            controller.present(activityViewController, animated: true)
        }
    }

}

extension FavContent {

    static func new(moc: NSManagedObjectContext, _ uuid: UUID, line: Int64, folder: FavFolder) {
        let fav = FavContent(context: moc)
        fav.id = UUID()
        fav.line = line
        fav.lawId = uuid
        fav.folder = folder
        try? moc.save()
    }

}

extension UUID {

    /* 将 08f1c0c5de2048c38eb96667f1adad12 转换成 UUID */
    static func create(str: String) -> UUID {
        var arr = [""]
        let size = [8,4,4,4,12]
        for char in str {
            if arr.last!.count == size[arr.count - 1] {
                arr.append("")
            }
            arr[arr.count - 1] = arr[arr.count - 1] + String(char)
        }
        return UUID(uuidString: arr.joined(separator: "-"))!
    }

    func asDBString() -> String {
        return self.uuidString.replacingOccurrences(of: "-", with: "").lowercased()
    }
}

extension String {
    
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

