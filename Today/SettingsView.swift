import SwiftUI

struct SettingsView: View {
    @ObservedObject var manager: MenuBarManager
    @Environment(\.dismiss) var dismiss
    @State private var launchAtLogin = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack {
                Text("Launch at login")
                    .foregroundColor(.secondary)
                Spacer()
                Toggle("", isOn: $launchAtLogin)
                    .labelsHidden()
                    .controlSize(.small)
            }
            
            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Morning range")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        DatePicker("", selection: $manager.morningStartTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .frame(width: 85)
                        
                        Text("～")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 2)
                        
                        DatePicker("", selection: $manager.morningEndTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .frame(width: 85)
                    }
                    
                    HStack {
                        Text("Afternoon range")
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        DatePicker("", selection: $manager.afternoonStartTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .frame(width: 85)
                        
                        Text("～")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 2)
                        
                        DatePicker("", selection: $manager.afternoonEndTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                            .frame(width: 85)
                    }
                }
                .padding(8)
            }
        }
        .padding(20)
        .frame(width: 380)
    }
}

#Preview {
    SettingsView(manager: MenuBarManager())
} 