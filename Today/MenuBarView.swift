import SwiftUI
import DGCharts

struct MenuBarView: View {
    let progress: Double
    
    private var pieChartView: some View {
        PieChartViewRepresentable(progress: progress)
            .frame(width: 16, height: 16)
            .scaleEffect(0.9)
    }
    
    var body: some View {
        pieChartView
            .padding(.horizontal, 2)
            .frame(height: 22)
    }
}

struct PieChartViewRepresentable: NSViewRepresentable {
    let progress: Double
    
    func makeNSView(context: Context) -> PieChartView {
        let chart = PieChartView()
        chart.minOffset = 0
        chart.setExtraOffsets(left: 0, top: 0, right: 0, bottom: 0)
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
            NSUIColor.black.withAlphaComponent(0.8),  // 深色部分（已完成）
            NSUIColor.black.withAlphaComponent(0.1)   // 浅色部分（未完成）
        ]
        dataSet.drawValuesEnabled = false
        dataSet.sliceSpace = 0
        dataSet.selectionShift = 0
        
        // 配置图表
        let data = PieChartData(dataSet: dataSet)
        chart.data = data
        
        // 基本设置
        chart.holeRadiusPercent = 0
        chart.transparentCircleRadiusPercent = 0
        chart.drawEntryLabelsEnabled = false
        chart.legend.enabled = false
        chart.rotationEnabled = false
        chart.highlightPerTapEnabled = false
        
        // 移除所有额外的视觉元素
        chart.drawHoleEnabled = false
        chart.maxAngle = 360
        
        // 移除所有边距和额外空间
        chart.minOffset = 0
        chart.extraLeftOffset = 0
        chart.extraRightOffset = 0
        chart.extraTopOffset = 0
        chart.extraBottomOffset = 0
        
        // 设置起始角度为-90度（顶部），这样进度会从顶部向右增长
        chart.rotationAngle = -90
        
        // 确保图表更新
        chart.notifyDataSetChanged()
    }
}

#Preview {
    MenuBarView(progress: 0.7)
        .frame(width: 24, height: 22)
        .background(Color.white)
} 