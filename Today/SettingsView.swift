import SwiftUI

struct SettingsView: View {
    @ObservedObject var manager: MenuBarManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("工作时间设置")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("上班时间：")
                    DatePicker("", selection: $manager.workStartTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                
                HStack {
                    Text("下班时间：")
                    DatePicker("", selection: $manager.workEndTime, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
            }
            .padding(.horizontal)
            
            Divider()
            
            HStack {
                Button("取消") {
                    dismiss()
                }
                
                Button("保存") {
                    // 触发设置更新
                    manager.updateSettings()
                    dismiss()
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(.top)
        }
        .padding()
        .frame(width: 300)
    }
}

#Preview {
    SettingsView(manager: MenuBarManager())
} 