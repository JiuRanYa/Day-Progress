import SwiftUI
import AppKit

class MenuBarManager: NSObject, ObservableObject {
    private var statusItem: NSStatusItem?
    private var timer: Timer?
    private var settingsWindow: NSWindow?
    
    @Published var workStartTime: Date
    @Published var workEndTime: Date
    
    override init() {
        workStartTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        workEndTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
        
        super.init()
        
        DispatchQueue.main.async { [weak self] in
            self?.setupStatusItem()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: 30)
        updateMenuBarView()
        setupMenu()
        startTimer()
    }
    
    private func setupMenu() {
        let menu = NSMenu()
        
        // 添加进度信息
        let progressItem = NSMenuItem()
        let progressView = NSHostingView(rootView: ProgressInfoView(progress: calculateProgress(), remainingTime: calculateRemainingTime()))
        progressView.frame = NSRect(x: 0, y: 0, width: 200, height: 60)
        progressItem.view = progressView
        menu.addItem(progressItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 添加设置选项
        let settingsItem = NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        // 添加更多选项
        let moreItem = NSMenuItem(title: "More", action: nil, keyEquivalent: "")
        menu.addItem(moreItem)
        
        menu.addItem(NSMenuItem.separator())
        
        // 添加退出选项
        let quitItem = NSMenuItem(title: "Quit Day Progress", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        statusItem?.menu = menu
    }
    
    @objc private func openSettings() {
        if settingsWindow == nil {
            let settingsView = SettingsView(manager: self)
            settingsWindow = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 300, height: 200),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            settingsWindow?.center()
            settingsWindow?.title = "设置"
            settingsWindow?.contentView = NSHostingView(rootView: settingsView)
            settingsWindow?.isReleasedWhenClosed = false
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    func updateSettings() {
        // 更新设置后刷新显示
        updateMenuBarView()
        updateMenu()
        
        // 保存设置到用户默认值
        saveSettings()
    }
    
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(workStartTime.timeIntervalSince1970, forKey: "workStartTime")
        defaults.set(workEndTime.timeIntervalSince1970, forKey: "workEndTime")
    }
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        if let startTimeInterval = defaults.object(forKey: "workStartTime") as? TimeInterval {
            workStartTime = Date(timeIntervalSince1970: startTimeInterval)
        }
        if let endTimeInterval = defaults.object(forKey: "workEndTime") as? TimeInterval {
            workEndTime = Date(timeIntervalSince1970: endTimeInterval)
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateMenuBarView()
                self?.updateMenu()
            }
        }
        timer?.tolerance = 1.0
    }
    
    private func updateMenu() {
        guard let menu = statusItem?.menu,
              let progressItem = menu.items.first,
              let progressView = progressItem.view as? NSHostingView<ProgressInfoView> else { return }
        
        progressView.rootView = ProgressInfoView(progress: calculateProgress(), remainingTime: calculateRemainingTime())
    }
    
    private func updateMenuBarView() {
        guard let button = statusItem?.button else { return }
        
        let menuBarView = MenuBarView(progress: calculateProgress())
        let hostingView = NSHostingView(rootView: menuBarView)
        hostingView.frame = NSRect(x: 0, y: 0, width: 30, height: 22)
        
        button.subviews.forEach { $0.removeFromSuperview() }
        button.addSubview(hostingView)
    }
    
    private func calculateProgress() -> Double {
        let now = Date()
        let calendar = Calendar.current
        
        let today = calendar.startOfDay(for: now)
        let workStart = calendar.date(bySettingHour: calendar.component(.hour, from: workStartTime),
                                    minute: calendar.component(.minute, from: workStartTime),
                                    second: 0,
                                    of: today) ?? now
        let workEnd = calendar.date(bySettingHour: calendar.component(.hour, from: workEndTime),
                                  minute: calendar.component(.minute, from: workEndTime),
                                  second: 0,
                                  of: today) ?? now
        
        let totalWorkDuration = workEnd.timeIntervalSince(workStart)
        let elapsedTime = now.timeIntervalSince(workStart)
        
        let progress = elapsedTime / totalWorkDuration
        return min(max(progress, 0), 1)
    }
    
    private func calculateRemainingTime() -> String {
        let now = Date()
        let calendar = Calendar.current
        
        let today = calendar.startOfDay(for: now)
        let workEnd = calendar.date(bySettingHour: calendar.component(.hour, from: workEndTime),
                                  minute: calendar.component(.minute, from: workEndTime),
                                  second: 0,
                                  of: today) ?? now
        
        let remainingTime = workEnd.timeIntervalSince(now)
        let hours = Int(remainingTime) / 3600
        let minutes = Int(remainingTime) / 60 % 60
        
        return "\(hours) hrs \(minutes) min until end of day"
    }
} 