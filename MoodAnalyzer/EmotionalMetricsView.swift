//
//  EmotionalMetricsView.swift
//  MoodAnalyzer
//
//  Created on 3/1/25.
//

import SwiftUI

struct EmotionalMetrics {
    var expressionLevel: Double // 0-1
    var emotionalBalance: Double // 0-1
    var creativeEnergy: Double // 0-1
    var joy: Double // 0-1
    var calm: Double // 0-1
    var energy: Double // 0-1
    var tension: Double // 0-1
    var expression: Double // 0-1
    
    // Classification functions
    var expressionLevelText: String {
        if expressionLevel >= 0.7 { return "High" }
        else if expressionLevel >= 0.4 { return "Moderate" }
        else { return "Low" }
    }
    
    var emotionalBalanceText: String {
        if emotionalBalance >= 0.7 { return "Strong" }
        else if emotionalBalance >= 0.4 { return "Moderate" }
        else { return "Fragile" }
    }
    
    var creativeEnergyText: String {
        if creativeEnergy >= 0.7 { return "High" }
        else if creativeEnergy >= 0.4 { return "Moderate" }
        else { return "Low" }
    }
    
    var expressionDirection: String {
        if expressionLevel > 0.5 { return "Positive" }
        else { return "Reserved" }
    }
    
    var balanceDirection: String {
        if emotionalBalance > 0.5 { return "Stable" }
        else { return "Variable" }
    }
    
    var energyDirection: String {
        if creativeEnergy > 0.5 { return "Dynamic" }
        else { return "Steady" }
    }
}

struct AnalysisMetricsView: View {
    let metrics: EmotionalMetrics
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                
                Text("Analysis Metrics")
                    .font(.title)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 10)
            
            HStack(spacing: 20) {
                metricBlock(
                    title: "Expression Level",
                    value: metrics.expressionLevelText,
                    direction: metrics.expressionDirection,
                    isPositive: metrics.expressionLevel > 0.5
                )
                
                metricBlock(
                    title: "Emotional Balance",
                    value: metrics.emotionalBalanceText,
                    direction: metrics.balanceDirection,
                    isPositive: metrics.emotionalBalance > 0.5
                )
                
                metricBlock(
                    title: "Creative Energy",
                    value: metrics.creativeEnergyText,
                    direction: metrics.energyDirection,
                    isPositive: metrics.creativeEnergy > 0.5
                )
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 15)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
    
    private func metricBlock(title: String, value: String, direction: String, isPositive: Bool) -> some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.callout)
                .fontWeight(.medium)
                .foregroundColor(.gray)
            
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .padding(.vertical, 1)
            
            HStack {
                Image(systemName: isPositive ? "arrow.up" : "arrow.down")
                    .foregroundColor(isPositive ? .green : .orange)
                
                Text(direction)
                    .foregroundColor(isPositive ? .green : .orange)
                    .fontWeight(.medium)
            }
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}

struct EmotionalProfileChart: View {
    let metrics: EmotionalMetrics
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Emotional Expression Profile")
                .font(.headline)
                .padding(.bottom, 10)
            
            RadarChart(
                data: [
                    metrics.calm,
                    metrics.joy,
                    metrics.expression,
                    metrics.tension,
                    metrics.energy
                ],
                labels: ["Calm", "Joy", "Expression", "Tension", "Energy"]
            )
            .frame(height: 300)
        }
        .padding()
        .background(Color(UIColor.systemGray6))
        .cornerRadius(10)
    }
}

struct RadarChart: View {
    let data: [Double] // Values between 0 and 1
    let labels: [String]
    
    private let gridColor = Color.gray.opacity(0.3)
    private let dataColor = Color.blue.opacity(0.5)
    private let outlineColor = Color.blue
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background circles
                ForEach(0..<4) { i in
                    let scale = Double(i + 1) / 5.0
                    Circle()
                        .stroke(gridColor, lineWidth: 1)
                        .frame(width: geometry.size.width * CGFloat(scale),
                               height: geometry.size.width * CGFloat(scale))
                }
                
                // Axis lines
                ForEach(0..<data.count, id: \.self) { i in
                    Path { path in
                        path.move(to: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2))
                        path.addLine(to: pointOnCircle(
                            center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                            radius: geometry.size.width/2,
                            angle: angleFor(index: i, total: data.count)
                        ))
                    }
                    .stroke(gridColor, lineWidth: 1)
                }
                
                // Labels
                ForEach(0..<data.count, id: \.self) { i in
                    let point = pointOnCircle(
                        center: CGPoint(x: geometry.size.width/2, y: geometry.size.height/2),
                        radius: geometry.size.width/2 + 15, // Position just outside the radar
                        angle: angleFor(index: i, total: data.count)
                    )
                    
                    Text(labels[i])
                        .font(.caption)
                        .position(point)
                }
                
                // Data polygon
                dataPolygon(in: geometry.size)
                    .fill(dataColor)
                
                // Data polygon outline
                dataPolygon(in: geometry.size)
                    .stroke(outlineColor, lineWidth: 2)
                
                // Value labels along axes
                ForEach(1..<5) { i in
                    let value = Double(i) * 0.2
                    Text(String(format: "%.1f", value))
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                        .position(x: geometry.size.width/2,
                                 y: geometry.size.height/2 - CGFloat(value) * geometry.size.height/2 + 5)
                }
            }
        }
    }
    
    private func dataPolygon(in size: CGSize) -> Path {
        Path { path in
            for (index, value) in data.enumerated() {
                let point = pointOnCircle(
                    center: CGPoint(x: size.width/2, y: size.height/2),
                    radius: size.width/2 * CGFloat(value),
                    angle: angleFor(index: index, total: data.count)
                )
                
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
        }
    }
    
    private func angleFor(index: Int, total: Int) -> Double {
        // Start from the top (270°) and go clockwise
        let angleSize = (2 * Double.pi) / Double(total)
        return Double.pi * 1.5 + angleSize * Double(index)
    }
    
    private func pointOnCircle(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        let x = center.x + radius * CGFloat(cos(angle))
        let y = center.y + radius * CGFloat(sin(angle))
        return CGPoint(x: x, y: y)
    }
}

// Helper extension to calculate emotion metrics from responses and drawing analysis
extension EmotionalMetrics {
    static func calculateFromAssessment(
        responses: [(question: Question, score: Int)],
        drawingAnalysis: String,
        categoryPercentages: [String: Double]
    ) -> EmotionalMetrics {
        // Calculate average score from questionnaire (0-1 scale)
        let avgScore = categoryPercentages.values.reduce(0.0, +) / Double(categoryPercentages.count) / 100.0
        
        // Extract emotional indicators from drawing analysis
        let lowerAnalysis = drawingAnalysis.lowercased()
        
        // Expression level calculation
        var expressionLevel = avgScore
        if lowerAnalysis.contains("expressive") || lowerAnalysis.contains("vibrant") {
            expressionLevel += 0.15
        }
        if lowerAnalysis.contains("detailed") || lowerAnalysis.contains("elaborate") {
            expressionLevel += 0.1
        }
        expressionLevel = min(max(expressionLevel, 0.0), 1.0)
        
        // Emotional balance calculation (higher is more balanced)
        var emotionalBalance = avgScore
        // Adjust based on resilience category if available
        if let resilienceScore = categoryPercentages["Resilience & Coping"] {
            emotionalBalance = (emotionalBalance + (resilienceScore / 100.0)) / 2.0
        }
        if lowerAnalysis.contains("balanced") || lowerAnalysis.contains("harmony") {
            emotionalBalance += 0.1
        }
        if lowerAnalysis.contains("chaotic") || lowerAnalysis.contains("conflicted") {
            emotionalBalance -= 0.1
        }
        emotionalBalance = min(max(emotionalBalance, 0.0), 1.0)
        
        // Creative energy calculation
        var creativeEnergy = 0.5 // Start at neutral
        if lowerAnalysis.contains("creative") || lowerAnalysis.contains("imaginative") {
            creativeEnergy += 0.2
        }
        if lowerAnalysis.contains("colorful") || lowerAnalysis.contains("dynamic") {
            creativeEnergy += 0.15
        }
        if lowerAnalysis.contains("monotone") || lowerAnalysis.contains("rigid") {
            creativeEnergy -= 0.1
        }
        creativeEnergy = min(max(creativeEnergy, 0.0), 1.0)
        
        // Other emotional dimensions
        var joy = 0.5
        if lowerAnalysis.contains("happy") || lowerAnalysis.contains("joy") {
            joy += 0.2
        }
        if lowerAnalysis.contains("sad") || lowerAnalysis.contains("somber") {
            joy -= 0.15
        }
        // Factor in satisfaction scores if available
        if let satisfactionScore = categoryPercentages["Satisfaction & Contentment"] {
            joy = (joy + (satisfactionScore / 100.0)) / 2.0
        }
        joy = min(max(joy, 0.0), 1.0)
        
        var calm = 0.5
        // Adjust based on anxiety scores if available
        if let anxietyScore = categoryPercentages["Anxiety & Stress Management"] {
            calm = 1.0 - (anxietyScore / 100.0) * 0.5 // Invert and scale
        }
        if lowerAnalysis.contains("calm") || lowerAnalysis.contains("peaceful") {
            calm += 0.15
        }
        if lowerAnalysis.contains("anxious") || lowerAnalysis.contains("tense") {
            calm -= 0.15
        }
        calm = min(max(calm, 0.0), 1.0)
        
        var energy = expressionLevel * 0.7 + creativeEnergy * 0.3
        if lowerAnalysis.contains("energetic") || lowerAnalysis.contains("vibrant") {
            energy += 0.1
        }
        if lowerAnalysis.contains("subdued") || lowerAnalysis.contains("low energy") {
            energy -= 0.1
        }
        energy = min(max(energy, 0.0), 1.0)
        
        var tension = 0.5
        if lowerAnalysis.contains("tense") || lowerAnalysis.contains("stress") {
            tension += 0.2
        }
        if lowerAnalysis.contains("relaxed") || lowerAnalysis.contains("ease") {
            tension -= 0.15
        }
        // Factor in stress-related categories
        if let anxietyScore = categoryPercentages["Anxiety & Stress Management"] {
            tension = (tension + (anxietyScore / 100.0) * 0.8) / 2.0
        }
        tension = min(max(tension, 0.0), 1.0)
        
        var expression = expressionLevel * 0.8 + creativeEnergy * 0.2
        if lowerAnalysis.contains("expressive") || lowerAnalysis.contains("communicative") {
            expression += 0.1
        }
        if lowerAnalysis.contains("withdrawn") || lowerAnalysis.contains("reserved") {
            expression -= 0.1
        }
        // Factor in social connection if available
        if let socialScore = categoryPercentages["Social Connection & Loneliness"] {
            expression = (expression + (socialScore / 100.0) * 0.7) / 2.0
        }
        expression = min(max(expression, 0.0), 1.0)
        
        return EmotionalMetrics(
            expressionLevel: expressionLevel,
            emotionalBalance: emotionalBalance,
            creativeEnergy: creativeEnergy,
            joy: joy,
            calm: calm,
            energy: energy,
            tension: tension,
            expression: expression
        )
    }
}
