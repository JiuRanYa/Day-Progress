import SwiftUI

struct ProgressInfoView: View {
    let progress: Double
    let remainingTime: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(Int(progress * 100))%")
                .font(.system(size: 24, weight: .medium))
            
            Text(remainingTime)
                .font(.system(size: 14))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

#Preview {
    ProgressInfoView(progress: 0.64, remainingTime: "8 hrs 44 min until end of day")
        .frame(width: 200)
} 