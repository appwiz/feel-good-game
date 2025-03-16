import Foundation
import GameKit

// This file defines all Game Center achievements for the Feel Good game

struct GameCenterAchievements {
    // Achievement identifiers for score milestones
    static let scoreAchievements: [Int: String] = [
        100: "achievement_100_taps",
        500: "achievement_500_taps",
        1000: "achievement_1000_taps",
        5000: "achievement_5000_taps",
        10000: "achievement_10000_taps",
        50000: "achievement_50000_taps",
        100000: "achievement_100000_taps",
        500000: "achievement_500000_taps"
    ]
    
    // Achievement identifiers for flower milestones
    static let flowerAchievements: [Int: String] = [
        10: "flowers_10",
        50: "flowers_50",
        100: "flowers_100"
    ]
    
    // Achievement descriptions for UI display
    static let achievementDescriptions: [String: String] = [
        "achievement_100_taps": "Tap 100 rectangles",
        "achievement_500_taps": "Tap 500 rectangles",
        "achievement_1000_taps": "Tap 1,000 rectangles",
        "achievement_5000_taps": "Tap 5,000 rectangles",
        "achievement_10000_taps": "Tap 10,000 rectangles",
        "achievement_50000_taps": "Tap 50,000 rectangles",
        "achievement_100000_taps": "Tap 100,000 rectangles",
        "achievement_500000_taps": "Tap 500,000 rectangles",
        "flowers_10": "See 10 flowers",
        "flowers_50": "See 50 flowers",
        "flowers_100": "See 100 flowers"
    ]
    
    // Achievement points for each achievement
    static let achievementPoints: [String: Int] = [
        "achievement_100_taps": 5,
        "achievement_500_taps": 10,
        "achievement_1000_taps": 20,
        "achievement_5000_taps": 30,
        "achievement_10000_taps": 40,
        "achievement_50000_taps": 50,
        "achievement_100000_taps": 75,
        "achievement_500000_taps": 100,
        "flowers_10": 10,
        "flowers_50": 25,
        "flowers_100": 50
    ]
    
    // Get achievement description
    static func description(for identifier: String) -> String {
        return achievementDescriptions[identifier] ?? "Unknown achievement"
    }
    
    // Get achievement points
    static func points(for identifier: String) -> Int {
        return achievementPoints[identifier] ?? 0
    }
    
    // Get achievement identifier for score
    static func identifier(for score: Int) -> String? {
        var highestThreshold = 0
        
        for threshold in scoreAchievements.keys.sorted() {
            if score >= threshold {
                highestThreshold = threshold
            } else {
                break
            }
        }
        
        return highestThreshold > 0 ? scoreAchievements[highestThreshold] : nil
    }
    
    // Get achievement identifier for flower count
    static func identifier(for flowerCount: Int) -> String? {
        var highestThreshold = 0
        
        for threshold in flowerAchievements.keys.sorted() {
            if flowerCount >= threshold {
                highestThreshold = threshold
            } else {
                break
            }
        }
        
        return highestThreshold > 0 ? flowerAchievements[highestThreshold] : nil
    }
    
    // Get achievement progress for score
    static func progress(for score: Int) -> [(String, Double)] {
        var progress: [(String, Double)] = []
        
        for (threshold, identifier) in scoreAchievements.sorted(by: { $0.key < $1.key }) {
            let percentComplete = min(Double(score) / Double(threshold) * 100.0, 100.0)
            progress.append((identifier, percentComplete))
        }
        
        return progress
    }
    
    // Get achievement progress for flower count
    static func progress(for flowerCount: Int) -> [(String, Double)] {
        var progress: [(String, Double)] = []
        
        for (threshold, identifier) in flowerAchievements.sorted(by: { $0.key < $1.key }) {
            let percentComplete = min(Double(flowerCount) / Double(threshold) * 100.0, 100.0)
            progress.append((identifier, percentComplete))
        }
        
        return progress
    }
}
