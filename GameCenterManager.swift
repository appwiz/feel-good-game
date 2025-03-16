import Foundation
import GameKit
import SwiftUI
import Combine

class GameCenterManager: NSObject, GKGameCenterControllerDelegate, ObservableObject {
    static let shared = GameCenterManager()
    
    // Published properties for UI updates
    @Published var isAuthenticated = false
    @Published var playerName: String = "Player"
    @Published var playerPhoto: UIImage?
    @Published var isAuthenticating = false
    @Published var lastError: String?
    
    // Achievement progress tracking
    @Published var achievementProgress: [String: Double] = [:]
    @Published var recentlyUnlockedAchievements: [String] = []
    
    // Initialize and authenticate with Game Center
    func authenticatePlayer() {
        isAuthenticating = true
        lastError = nil
        
        let localPlayer = GKLocalPlayer.local
        
        localPlayer.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isAuthenticating = false
                
                if let viewController = viewController {
                    // Store the authentication view controller for later presentation
                    // In a real app with UIKit, we would present this view controller
                    print("Game Center authentication view controller should be presented")
                    self.lastError = "Game Center requires authentication. Please sign in through Settings."
                } else if localPlayer.isAuthenticated {
                    // Player is authenticated
                    self.isAuthenticated = true
                    self.lastError = nil
                    print("Player authenticated with Game Center")
                    
                    // Load player info
                    self.loadPlayerInfo()
                    
                    // Load achievements
                    self.loadAchievements()
                    
                    // Register for challenges
                    self.registerForChallenges()
                } else {
                    // Player is not authenticated
                    self.isAuthenticated = false
                    self.lastError = error?.localizedDescription ?? "Game Center authentication failed"
                    print("Game Center authentication failed: \(error?.localizedDescription ?? "Unknown error")")
                }
            }
        }
    }
    
    // Load player information
    private func loadPlayerInfo() {
        let localPlayer = GKLocalPlayer.local
        
        // Get player name
        playerName = localPlayer.displayName
        
        // Load player photo if available
        localPlayer.loadPhoto(for: .normal) { [weak self] (image, error) in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let image = image {
                    self.playerPhoto = image
                } else if let error = error {
                    print("Error loading player photo: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Register for challenges
    private func registerForChallenges() {
        GKLocalPlayer.local.register(self)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(challengesDidChange),
            name: NSNotification.Name.GKPlayerDidReceiveChallengeNotification,
            object: nil
        )
    }
    
    @objc private func challengesDidChange(_ notification: Notification) {
        if let challenge = notification.object as? GKChallenge {
            print("Received challenge: \(challenge)")
        }
    }
    
    // Report score to Game Center
    func reportScore(_ score: Int) {
        guard isAuthenticated else { return }
        
        let scoreReporter = GKScore(leaderboardIdentifier: "main_leaderboard")
        scoreReporter.value = Int64(score)
        
        GKScore.report([scoreReporter]) { error in
            if let error = error {
                print("Error reporting score: \(error.localizedDescription)")
            } else {
                print("Score reported successfully")
            }
        }
    }
    
    // Report achievement progress for score
    func reportAchievement(for score: Int) {
        guard isAuthenticated else { 
            print("Not reporting achievements: player not authenticated")
            return 
        }
        
        // Get all score achievements with their progress
        let scoreAchievements = GameCenterAchievements.progress(for: score)
        
        // Report each achievement with its progress
        for (identifier, percentComplete) in scoreAchievements {
            reportAchievement(identifier: identifier, percentComplete: percentComplete)
        }
    }
    
    // Report achievement progress for flower count
    func reportFlowerAchievement(for flowerCount: Int) {
        guard isAuthenticated else { return }
        
        // Get all flower achievements with their progress
        let flowerAchievements = GameCenterAchievements.progress(for: flowerCount)
        
        // Report each achievement with its progress
        for (identifier, percentComplete) in flowerAchievements {
            reportAchievement(identifier: identifier, percentComplete: percentComplete)
        }
    }
    
    // Generic method to report achievement progress
    func reportAchievement(identifier: String, percentComplete: Double) {
        guard isAuthenticated else { return }
        
        // Check if we already have this achievement at 100%
        if let currentProgress = achievementProgress[identifier], currentProgress >= 100.0 {
            // Already completed, no need to report again
            return
        }
        
        let achievement = GKAchievement(identifier: identifier)
        
        // Set completion percentage
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        
        // Update local tracking
        let wasCompleted = achievementProgress[identifier] ?? 0 < 100.0 && percentComplete >= 100.0
        achievementProgress[identifier] = percentComplete
        
        // If newly completed, add to recently unlocked list
        if wasCompleted {
            DispatchQueue.main.async {
                self.recentlyUnlockedAchievements.append(identifier)
                
                // Remove from recently unlocked after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
                    if let index = self.recentlyUnlockedAchievements.firstIndex(of: identifier) {
                        self.recentlyUnlockedAchievements.remove(at: index)
                    }
                }
            }
        }
        
        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("Error reporting achievement \(identifier): \(error.localizedDescription)")
            } else {
                print("Achievement \(identifier) reported successfully")
            }
        }
    }
    
    // Load achievements
    private func loadAchievements() {
        GKAchievement.loadAchievements { [weak self] achievements, error in
            guard let self = self else { return }
            
            if let error = error {
                print("Error loading achievements: \(error.localizedDescription)")
                return
            }
            
            print("Loaded \(achievements?.count ?? 0) achievements")
            
            // Update local achievement progress tracking
            DispatchQueue.main.async {
                if let achievements = achievements {
                    for achievement in achievements {
                        self.achievementProgress[achievement.identifier] = achievement.percentComplete
                    }
                }
            }
        }
    }
    
    // Get achievement progress
    func getAchievementProgress(for identifier: String) -> Double {
        return achievementProgress[identifier] ?? 0.0
    }
    
    // Check if achievement is recently unlocked
    func isRecentlyUnlocked(identifier: String) -> Bool {
        return recentlyUnlockedAchievements.contains(identifier)
    }
    
    // Show Game Center achievements
    func showAchievements() {
        guard isAuthenticated else { 
            print("Cannot show achievements: player not authenticated")
            return 
        }
        
        let viewController = GKGameCenterViewController(state: .achievements)
        viewController.gameCenterDelegate = self
        
        // In a SwiftUI app, we would use UIViewControllerRepresentable
        // For now, just log that we would show the view controller
        print("Would show Game Center achievements view controller")
    }
    
    // Show Game Center leaderboards
    func showLeaderboards() {
        guard isAuthenticated else { 
            print("Cannot show leaderboards: player not authenticated")
            return 
        }
        
        let viewController = GKGameCenterViewController(state: .leaderboards)
        viewController.gameCenterDelegate = self
        
        // In a SwiftUI app, we would use UIViewControllerRepresentable
        // For now, just log that we would show the view controller
        print("Would show Game Center leaderboards view controller")
    }
    
    // Reset achievements (for testing)
    func resetAchievements() {
        guard isAuthenticated else { return }
        
        GKAchievement.resetAchievements { error in
            if let error = error {
                print("Error resetting achievements: \(error.localizedDescription)")
            } else {
                print("Achievements reset successfully")
            }
        }
    }
    
    // GKGameCenterControllerDelegate
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        // In a real app, we would dismiss the view controller
        print("Game Center view controller should be dismissed")
    }
}
