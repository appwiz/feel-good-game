import SwiftUI
import Combine
import GameKit

class GameState: ObservableObject {
    @Published var score: Int = 0
    @Published var flowersSeen: Int = 0
    @Published var isPaused: Bool = false
    @Published var rectangleAppearanceInterval: Double = 2.0 // Default 2 seconds
    @Published var isSyncing: Bool = false
    
    // Settings bounds
    let minInterval: Double = 0.1
    let maxInterval: Double = 5.0
    
    // Achievement thresholds
    let achievementThresholds = [100, 500, 1000, 5000, 10000, 50000, 100000, 500000]
    
    // Save game state
    func saveState() {
        // Save locally first
        UserDefaults.standard.set(score, forKey: "score")
        UserDefaults.standard.set(flowersSeen, forKey: "flowersSeen")
        UserDefaults.standard.set(rectangleAppearanceInterval, forKey: "rectangleAppearanceInterval")
        
        // Check for achievements
        checkAchievements()
        
        // Sync to iCloud
        syncToCloud()
    }
    
    // Load game state
    func loadState() {
        // Load from local storage first
        let localScore = UserDefaults.standard.integer(forKey: "score")
        let localFlowersSeen = UserDefaults.standard.integer(forKey: "flowersSeen")
        let localInterval = UserDefaults.standard.double(forKey: "rectangleAppearanceInterval")
        
        // Set initial values from local storage
        score = localScore
        flowersSeen = localFlowersSeen
        rectangleAppearanceInterval = localInterval
        
        if rectangleAppearanceInterval < minInterval || rectangleAppearanceInterval > maxInterval {
            rectangleAppearanceInterval = 2.0 // Reset to default if out of bounds
        }
        
        // Try to load from iCloud
        loadFromCloud()
    }
    
    // Sync to iCloud
    private func syncToCloud() {
        isSyncing = true
        
        CloudKitManager.shared.saveGameState(
            score: score,
            flowersSeen: flowersSeen,
            interval: rectangleAppearanceInterval
        ) { [weak self] error in
            DispatchQueue.main.async {
                self?.isSyncing = false
                
                if let error = error {
                    print("Error syncing to iCloud: \(error.localizedDescription)")
                    // Show sync error indicator if needed
                    self?.handleSyncError(error)
                } else {
                    print("Successfully synced to iCloud")
                    // Update last sync time display if needed
                    self?.updateLastSyncTime()
                }
            }
        }
    }
    
    // Load from iCloud
    private func loadFromCloud() {
        isSyncing = true
        
        CloudKitManager.shared.loadGameState { [weak self] result in
            DispatchQueue.main.async {
                self?.isSyncing = false
                
                switch result {
                case .success(let gameState):
                    // Compare cloud values with local values and use the higher ones
                    if let self = self {
                        if gameState.score > self.score {
                            self.score = gameState.score
                        }
                        
                        if gameState.flowersSeen > self.flowersSeen {
                            self.flowersSeen = gameState.flowersSeen
                        }
                        
                        // For interval, we'll use the cloud value if it's valid
                        if gameState.interval >= self.minInterval && gameState.interval <= self.maxInterval {
                            self.rectangleAppearanceInterval = gameState.interval
                        }
                        
                        // Save the merged state back to local storage
                        UserDefaults.standard.set(self.score, forKey: "score")
                        UserDefaults.standard.set(self.flowersSeen, forKey: "flowersSeen")
                        UserDefaults.standard.set(self.rectangleAppearanceInterval, forKey: "rectangleAppearanceInterval")
                        
                        print("Successfully loaded from iCloud")
                        self.updateLastSyncTime()
                    }
                    
                case .failure(let error):
                    print("Error loading from iCloud: \(error.localizedDescription)")
                    self?.handleSyncError(error)
                }
            }
        }
    }
    
    // Handle sync errors
    private func handleSyncError(_ error: Error) {
        // For now, just log the error
        // In a production app, we might want to show a UI indicator or retry mechanism
        print("iCloud sync error: \(error.localizedDescription)")
    }
    
    // Update last sync time display
    private func updateLastSyncTime() {
        if let lastSyncTime = CloudKitManager.shared.getLastSyncTime() {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            let timeString = formatter.string(from: lastSyncTime)
            print("Last synced: \(timeString)")
        }
    }
    
    // Increment flower count
    func incrementFlowerSeen() {
        flowersSeen += 1
        print("Flower seen! Total flowers: \(flowersSeen)")
        saveState()
    }
    
    // Pause game and save state
    func pauseGame() {
        isPaused = true
        saveState()
    }
    
    // Resume game
    func resumeGame() {
        isPaused = false
    }
    
    // Check for achievements
    private func checkAchievements() {
        // Report score and score-based achievements to Game Center
        GameCenterManager.shared.reportScore(score)
        GameCenterManager.shared.reportAchievement(for: score)
        
        // Report flower-related achievements
        GameCenterManager.shared.reportFlowerAchievement(for: flowersSeen)
    }
    
    // Reset game state (for testing)
    func resetState() {
        score = 0
        flowersSeen = 0
        rectangleAppearanceInterval = 2.0
        saveState()
    }
    
    // Initialize and load saved state
    init() {
        // Initialize Game Center
        GameCenterManager.shared.authenticatePlayer()
        
        // Load state
        loadState()
    }
}
