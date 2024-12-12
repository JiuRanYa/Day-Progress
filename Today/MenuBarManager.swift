import SwiftUI
import AppKit

class MenuBarManager: NSObject, ObservableObject {
    private var statusItem: NSStatusItem?
    private var timer: Timer?
    private var settingsWindow: NSWindow?
    
    @Published var morningStartTime: Date {
        didSet {
            updateDisplay()
            saveSettings()
        }
    }
    @Published var morningEndTime: Date {
        didSet {
            updateDisplay()
            saveSettings()
        }
    }
    @Published var afternoonStartTime: Date {
        didSet {
            updateDisplay()
            saveSettings()
        }
    }
    @Published var afternoonEndTime: Date {
        didSet {
            updateDisplay()
            saveSettings()
        }
    }
    
    override init() {
        // 初始化默认时间
        let calendar = Calendar.current
        morningStartTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        morningEndTime = calendar.date(bySettingHour: 12, minute: 0, second: 0, of: Date()) ?? Date()
        afternoonStartTime = calendar.date(bySettingHour: 13, minute: 0, second: 0, of: Date()) ?? Date()
        afternoonEndTime = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
        
        super.init()
        
        loadSettings()
        
        DispatchQueue.main.async { [weak self] in
            self?.setupStatusItem()
        }
    }
    
    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: 30)
        updateMenuBarView()
        setupMenu()
        startTimer()
    }
    
    private func updateDisplay() {
        DispatchQueue.main.async { [weak self] in
            self?.updateMenuBarView()
            self?.updateMenu()
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { [weak self] _ in
            self?.updateDisplay()
        }
        timer?.tolerance = 1.0
    }
    
    deinit {
        timer?.invalidate()
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
                contentRect: NSRect(x: 0, y: 0, width: 380, height: 300),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            settingsWindow?.center()
            settingsWindow?.title = "Day Progress Settings"
            settingsWindow?.contentView = NSHostingView(rootView: settingsView)
            settingsWindow?.isReleasedWhenClosed = false
        }
        
        settingsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
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
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentMinutes = hour * 60 + minute
        
        // 获取各个时间点的分钟数
        let morningStartMinutes = calendar.component(.hour, from: morningStartTime) * 60 + calendar.component(.minute, from: morningStartTime)
        let morningEndMinutes = calendar.component(.hour, from: morningEndTime) * 60 + calendar.component(.minute, from: morningEndTime)
        let afternoonStartMinutes = calendar.component(.hour, from: afternoonStartTime) * 60 + calendar.component(.minute, from: afternoonStartTime)
        let afternoonEndMinutes = calendar.component(.hour, from: afternoonEndTime) * 60 + calendar.component(.minute, from: afternoonEndTime)
        
        // 判断当前是上午还是下午时段
        let isInMorningPeriod = currentMinutes >= morningStartMinutes && currentMinutes < morningEndMinutes
        let isInAfternoonPeriod = currentMinutes >= afternoonStartMinutes && currentMinutes < afternoonEndMinutes
        
        if isInMorningPeriod {
            let totalMinutes = morningEndMinutes - morningStartMinutes
            let elapsedMinutes = currentMinutes - morningStartMinutes
            return Double(elapsedMinutes) / Double(totalMinutes)
        } else if isInAfternoonPeriod {
            let totalMinutes = afternoonEndMinutes - afternoonStartMinutes
            let elapsedMinutes = currentMinutes - afternoonStartMinutes
            return Double(elapsedMinutes) / Double(totalMinutes)
        }
        
        // 如果在工作时间之外
        if currentMinutes < morningStartMinutes {
            return 0
        } else {
            return 1
        }
    }
    
    private func calculateRemainingTime() -> String {
        let now = Date()
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: now)
        let minute = calendar.component(.minute, from: now)
        let currentMinutes = hour * 60 + minute
        
        // 获取各个时间点的分钟数
        let morningStartMinutes = calendar.component(.hour, from: morningStartTime) * 60 + calendar.component(.minute, from: morningStartTime)
        let morningEndMinutes = calendar.component(.hour, from: morningEndTime) * 60 + calendar.component(.minute, from: morningEndTime)
        let afternoonStartMinutes = calendar.component(.hour, from: afternoonStartTime) * 60 + calendar.component(.minute, from: afternoonStartTime)
        let afternoonEndMinutes = calendar.component(.hour, from: afternoonEndTime) * 60 + calendar.component(.minute, from: afternoonEndTime)
        
        // 判断当前是上午还是下午时段
        let isInMorningPeriod = currentMinutes >= morningStartMinutes && currentMinutes < morningEndMinutes
        let isInAfternoonPeriod = currentMinutes >= afternoonStartMinutes && currentMinutes < afternoonEndMinutes
        
        if isInMorningPeriod {
            let remainingMinutes = morningEndMinutes - currentMinutes
            let hours = remainingMinutes / 60
            let minutes = remainingMinutes % 60
            return "\(hours) hrs \(minutes) min until end of morning"
        } else if isInAfternoonPeriod {
            let remainingMinutes = afternoonEndMinutes - currentMinutes
            let hours = remainingMinutes / 60
            let minutes = remainingMinutes % 60
            return "\(hours) hrs \(minutes) min until end of day"
        } else {
            if currentMinutes < morningStartMinutes {
                return "Work hasn't started"
            } else {
                return "Work day ended"
            }
        }
    }
    
    private func saveSettings() {
        let defaults = UserDefaults.standard
        defaults.set(morningStartTime.timeIntervalSince1970, forKey: "morningStartTime")
        defaults.set(morningEndTime.timeIntervalSince1970, forKey: "morningEndTime")
        defaults.set(afternoonStartTime.timeIntervalSince1970, forKey: "afternoonStartTime")
        defaults.set(afternoonEndTime.timeIntervalSince1970, forKey: "afternoonEndTime")
    }
    
    private func loadSettings() {
        let defaults = UserDefaults.standard
        if let startTimeInterval = defaults.object(forKey: "morningStartTime") as? TimeInterval {
            morningStartTime = Date(timeIntervalSince1970: startTimeInterval)
        }
        if let endTimeInterval = defaults.object(forKey: "morningEndTime") as? TimeInterval {
            morningEndTime = Date(timeIntervalSince1970: endTimeInterval)
        }
        if let startTimeInterval = defaults.object(forKey: "afternoonStartTime") as? TimeInterval {
            afternoonStartTime = Date(timeIntervalSince1970: startTimeInterval)
        }
        if let endTimeInterval = defaults.object(forKey: "afternoonEndTime") as? TimeInterval {
            afternoonEndTime = Date(timeIntervalSince1970: endTimeInterval)
        }
    }
} 