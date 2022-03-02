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

func Report(law: LawContent, line: String){
    let subject = String(format: "反馈问题:%@", law.Titles)
    let body = line
    OpenMail(subject: subject, body: body)
}


func BarItem(_ icon: String, action: @escaping () -> Void ) -> ToolbarItem<Void, AnyView> {
    return ToolbarItem(placement: .navigationBarTrailing) {
        AnyView(
            Button(action: action, label: {
                Image(systemName: icon)
                    .foregroundColor(.red)
            })
        )
    }
}


func TextBarItem(_ str: String, action: @escaping () -> Void ) -> ToolbarItem<Void, AnyView> {
    return ToolbarItem(placement: .navigationBarTrailing) {
        AnyView(
            Button(action: action, label: {
                Text(str)
                    .foregroundColor(.red)
            })
        )
    }
}

func readLocalFile(forName name: String) -> Data? {
    do {
        if let bundlePath = Bundle.main.path(forResource: name,
                                             ofType: "json"),
            let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
            return jsonData
        }
    } catch {
        print(error)
    }

    return nil
}
