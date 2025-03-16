import SwiftUI
import Combine

class RectangleGenerator: ObservableObject {
    @Published var currentRectangle: GameRectangle?
    @Published var showFlower: Bool = false
    
    private var timer: AnyCancellable?
    private var screenSize: CGSize = .zero
    private let flowerProbability: Double = 0.2 // 20% chance to show a flower
    
    // Start generating rectangles
    func startGenerating(interval: Double, in size: CGSize) {
        screenSize = size
        stopGenerating()
        
        timer = Timer.publish(every: interval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.generateNewRectangle()
            }
        
        // Generate first rectangle immediately
        generateNewRectangle()
    }
    
    // Stop generating rectangles
    func stopGenerating() {
        timer?.cancel()
        timer = nil
        currentRectangle = nil
        showFlower = false
    }
    
    // Generate a new rectangle in a random position
    private func generateNewRectangle() {
        guard screenSize != .zero else { return }
        
        // Rectangle size (30-40% of screen width/height)
        let width = screenSize.width * CGFloat.random(in: 0.3...0.4)
        let height = screenSize.height * CGFloat.random(in: 0.3...0.4)
        
        // Position (ensure fully within screen bounds)
        let x = CGFloat.random(in: 0...(screenSize.width - width))
        let y = CGFloat.random(in: 0...(screenSize.height - height))
        
        // Random color or gradient
        let colorType = Int.random(in: 0...2)
        let colors = generateRandomColors()
        
        currentRectangle = GameRectangle(
            frame: CGRect(x: x, y: y, width: width, height: height),
            colorType: colorType,
            colors: colors
        )
        
        showFlower = false
    }
    
    // Generate random colors for the rectangle
    private func generateRandomColors() -> [Color] {
        let availableColors: [Color] = [
            .red, .blue, .green, .yellow, .orange, .purple, .pink
        ]
        
        let color1 = availableColors.randomElement() ?? .blue
        let color2 = availableColors.randomElement() ?? .green
        
        return [color1, color2]
    }
    
    // Handle tap at a specific point
    func handleTap(at point: CGPoint) -> Bool {
        guard let rectangle = currentRectangle else { return false }
        
        if rectangle.frame.contains(point) {
            // Determine if we should show a flower
            showFlower = Double.random(in: 0...1) < flowerProbability
            
            // Play appropriate sound
            if showFlower {
                SoundManager.shared.playFlowerSound()
            } else {
                SoundManager.shared.playTapSound()
            }
            
            // Remove the rectangle (will be replaced on next timer tick)
            currentRectangle = nil
            return true
        }
        
        return false
    }
    
    // Update the interval
    func updateInterval(to newInterval: Double) {
        guard let oldTimer = timer else { return }
        
        oldTimer.cancel()
        
        timer = Timer.publish(every: newInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.generateNewRectangle()
            }
    }
}

// Struct to represent a game rectangle
struct GameRectangle {
    let frame: CGRect
    let colorType: Int // 0: solid, 1: linear gradient, 2: radial gradient
    let colors: [Color]
}
