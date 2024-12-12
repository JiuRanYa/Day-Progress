import SwiftUI

struct MenuBarView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 18, height: 18)
        .padding(.horizontal, 6)
    }
}

#Preview {
    MenuBarView(progress: 0.7)
        .frame(width: 30, height: 22)
        .background(Color.white)
} 