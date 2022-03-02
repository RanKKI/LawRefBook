//
//  law_handbookApp.swift
//  law.handbook
//
//  Created by Hugh Liu on 24/2/2022.
//

import SwiftUI


@main
struct MainApp: App {

    @StateObject private var dataController = DataController()
    @ObservedObject var manager: LawManager = LawManager()

    var body: some Scene {
        WindowGroup {
            ContentView(lawManager: manager)
                .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }

    init() {
        let launchedBefore = UserDefaults.standard.bool(forKey: "launchedBefore")
        if !launchedBefore  {
            self.firstRun()
            UserDefaults.standard.set(true, forKey: "launchedBefore")
        }
    }

    private func firstRun(){

    }

}
