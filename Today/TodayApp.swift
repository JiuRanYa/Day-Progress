//
//  TodayApp.swift
//  Today
//
//  Created by 久染 on 2024/12/12.
//

import SwiftUI

@main
struct TodayApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var menuBarManager: MenuBarManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        menuBarManager = MenuBarManager()
    }
}
