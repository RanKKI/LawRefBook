//
//  Util.swift
//  law.handbook
//
//  Created by HCM-B0208 on 2022/3/1.
//

import Foundation
import SwiftUI

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

func Report(law: LawModel, line: String){
    let subject = String(format: "反馈问题:%@", law.Titles)
    let body = line
    OpenMail(subject: subject, body: body)
}
