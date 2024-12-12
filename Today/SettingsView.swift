import SwiftUI

struct SettingsView: View {
    @ObservedObject var manager: MenuBarManager
    @Environment(\.dismiss) var dismiss
    @State private var launchAtLogin = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Toggle("Launch at login", isOn: $launchAtLogin)
            
            GroupBox {
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("Morning range")
                            .foregroundColor(.secondary)
                            .frame(width: 120, alignment: .leading)
                        
                        HStack(spacing: 12) {
                            DatePicker("", selection: $manager.morningStartTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .frame(width: 85)
                            
                            Text("–")
                                .foregroundColor(.secondary)
                            
                            DatePicker("", selection: $manager.morningEndTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .frame(width: 85)
                        }
                    }
                    
                    HStack {
                        Text("Afternoon range")
                            .foregroundColor(.secondary)
                            .frame(width: 120, alignment: .leading)
                        
                        HStack(spacing: 12) {
                            DatePicker("", selection: $manager.afternoonStartTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .frame(width: 85)
                            
                            Text("–")
                                .foregroundColor(.secondary)
                            
                            DatePicker("", selection: $manager.afternoonEndTime, displayedComponents: .hourAndMinute)
                                .labelsHidden()
                                .frame(width: 85)
                        }
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