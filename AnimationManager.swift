import SwiftUI

class AnimationManager {
    // Animation durations
    static let rectangleAppearDuration: Double = 0.3
    static let rectangleDisappearDuration: Double = 0.2
    static let flowerAppearDuration: Double = 0.5
    static let flowerDisappearDuration: Double = 0.3
    
    // Animation curves
    static let rectangleAppearCurve: Animation = .easeInOut(duration: rectangleAppearDuration)
    static let rectangleDisappearCurve: Animation = .easeOut(duration: rectangleDisappearDuration)
    static let flowerAppearCurve: Animation = .easeInOut(duration: flowerAppearDuration)
    static let flowerDisappearCurve: Animation = .easeOut(duration: flowerDisappearDuration)
    
    // Rectangle appear animation values
    static let rectangleInitialOpacity: Double = 0
    static let rectangleFinalOpacity: Double = 1
    static let rectangleInitialScale: CGFloat = 0.8
    static let rectangleFinalScale: CGFloat = 1
    
    // Rectangle disappear animation values
    static let rectangleDisappearOpacity: Double = 0
    static let rectangleDisappearScale: CGFloat = 1.2
    
    // Flower animation values
    static let flowerInitialOpacity: Double = 0
    static let flowerFinalOpacity: Double = 1
    static let flowerInitialScale: CGFloat = 0.5
    static let flowerFinalScale: CGFloat = 1
    static let flowerDisappearScale: CGFloat = 1.5
    static let flowerRotation: Double = 360
}
