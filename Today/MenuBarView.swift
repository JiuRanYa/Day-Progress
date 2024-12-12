import SwiftUI
import DGCharts

struct MenuBarView: View {
    let progress: Double
    
    private var pieChartView: some View {
        PieChartViewRepresentable(progress: progress)
            .frame(width: 16, height: 16)
    }
    
    var body: some View {
        pieChartView
            .padding(.horizontal, 7)
    }
}

struct PieChartViewRepresentable: NSViewRepresentable {
    let progress: Double
    
    func makeNSView(context: Context) -> PieChartView {
        let chart = PieChartView()
        updateChart(chart)
        return chart
    }
    
    func updateNSView(_ chart: PieChartView, context: Context) {
        updateChart(chart)
    }
    
    private func updateChart(_ chart: PieChartView) {
        // 创建数据
        let completed = PieChartDataEntry(value: progress * 100)
        let remaining = PieChartDataEntry(value: (1 - progress) * 100)
        let dataSet = PieChartDataSet(entries: [completed, remaining])
        
        // 设置样式
        dataSet.colors = [
            NSUIColor.black.withAlphaComponent(0.8), // 深色部分
            NSUIColor.black.withAlphaComponent(0.1)  // 浅色部分
        ]
        dataSet.drawValuesEnabled = false
        dataSet.sliceSpace = 0
        
        // 配置图表
        chart.data = PieChartData(dataSet: dataSet)
        chart.holeRadiusPercent = 0
        chart.transparentCircleRadiusPercent = 0
        chart.drawEntryLabelsEnabled = false
        chart.legend.enabled = false
        chart.rotationEnabled = false
        chart.highlightPerTapEnabled = false
        
        // 移除所有额外的视觉元素
        chart.drawHoleEnabled = false
        
        // 设置起始角度，使进度从顶部开始
        chart.rotationAngle = 90
        
        // 确保图表更新
        chart.notifyDataSetChanged()
    }
}

#Preview {
    MenuBarView(progress: 0.7)
        .frame(width: 30, height: 22)
        .background(Color.white)
} 