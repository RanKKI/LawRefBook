//
//  Mail.swift
//  RefBook
//
//  Created by Hugh Liu on 26/11/2022.
//

import Foundation
import UIKit

enum Mail {

    static func new(to: String, subject: String, body: String = "") {
        let mailTo = String(format: "mailto:%@?subject=%@&body=%@", to, subject, body)
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let mailtoUrl = URL(string: mailTo!)!
        if UIApplication.shared.canOpenURL(mailtoUrl) {
            UIApplication.shared.open(mailtoUrl, options: [:])
        }
    }

    static func new(subject: String, body: String = "") {
        new(to: DeveloperMail, subject: subject, body: body)
    }

    static func reportIssue(body: String = "") {
        new(subject: "反馈问题", body: String(format: "%@\n\nVersion:%@", body, UIApplication.appVersion ?? ""))
    }

    static func reportIssue(law: TLaw, content: String) {
        let subject = String(format: "反馈问题:%@", law.name)
        new(subject: subject, body: content)
    }
}
