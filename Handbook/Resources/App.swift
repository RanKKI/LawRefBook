//
//  law_handbookApp.swift
//  law.handbook
//
//  Created by Hugh Liu on 24/2/2022.
//

import SwiftUI


@main
struct MainApp: App {

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, LawProvider.shared.container.viewContext)
        }
    }

    init() {
        let launchedCnt = UserDefaults.standard.integer(forKey: "launchedCnt")
        if launchedCnt == 0 {
            self.firstRun()
        }
        UserDefaults.standard.set(launchedCnt + 1, forKey: "launchedCnt")
    
    }

    private func firstRun(){

    }

}
