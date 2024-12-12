import SwiftUI

struct SettingsView: View {
    @ObservedObject var manager: MenuBarManager
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("工作时间设置")
                .font(.headline)
            
            GroupBox("上午") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("开始时间：")
                        DatePicker("", selection: $manager.morningStartTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    HStack {
                        Text("结束时间：")
                        DatePicker("", selection: $manager.morningEndTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                .padding(.vertical, 8)
            }
            
            GroupBox("下午") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("开始时间：")
                        DatePicker("", selection: $manager.afternoonStartTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                    
                    HStack {
                        Text("结束时间：")
                        DatePicker("", selection: $manager.afternoonEndTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
                .padding(.vertical, 8)
            }
            
            Divider()
            
            HStack {
                Button("取消") {
                    dismiss()
                }
                
                Button("保存") {
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