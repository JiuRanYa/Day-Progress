import SwiftUI
import AppKit

class MenuBarManager: NSObject {
    private var statusItem: NSStatusItem?
    private var timer: Timer?
    
    @Published var workStartTime: Date
    @Published var workEndTime: Date
    
    override init() {
        // 初始化属性
        workStartTime = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
        workEndTime = Calendar.current.date(bySettingHour: 18, minute: 0, second: 0, of: Date()) ?? Date()
        
        super.init()
        
        // 在主线程上设置UI
        DispatchQueue.main.async { [weak self] in
            self?.setupStatusItem()
        }
    }
    
    deinit {
        timer?.invalidate()
    }
    
    private func setupStatusItem() {
        // 创建状态栏项
        statusItem = NSStatusBar.system.statusItem(withLength: 30)
        
        // 更新视图
        updateMenuBarView()
        
        // 设置菜单
        setupMenu()
        
        // 启动定时器
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
        // TODO: 实现设置窗口
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