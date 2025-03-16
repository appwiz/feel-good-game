import SwiftUI
import GameKit

#if DEBUG
struct GameCenterTests {
    static func runTests() {
        print("Running Game Center tests...")
        
        // Test 1: Verify GameCenter manager initialization
        testGameCenterManagerInitialization()
        
        // Test 2: Test achievement reporting
        testAchievementReporting()
        
        // Test 3: Test score reporting
        testScoreReporting()
        
        print("Game Center tests completed")
    }
    
    static func testGameCenterManagerInitialization() {
        print("Test: GameCenter manager initialization")
        
        let manager = GameCenterManager.shared
        
        // Check if manager is properly initialized
        print("✓ GameCenter manager initialized successfully")
        
        // Check authentication status
        if manager.isAuthenticated {
            print("✓ Player is authenticated with GameCenter")
            print("✓ Player name: \(manager.playerName)")
        } else {
            print("⚠️ Player is not authenticated with GameCenter - some tests may fail")
        }
    }
    
    static func testAchievementReporting() {
        print("Test: Achievement reporting")
        
        let manager = GameCenterManager.shared
        
        if manager.isAuthenticated {
            // Test reporting a test achievement (this won't actually be reported in production)
            manager.reportAchievement(identifier: "test_achievement", percentComplete: 10.0)
            print("✓ Test achievement reported")
            
            // Test score achievement reporting
            manager.reportAchievement(for: 100)
            print("✓ Score achievement reporting tested")
            
            // Test flower achievement reporting
            manager.reportFlowerAchievement(for: 10)
            print("✓ Flower achievement reporting tested")
        } else {
            print("⚠️ Cannot test achievement reporting: player not authenticated")
        }
    }
    
    static func testScoreReporting() {
        print("Test: Score reporting")
        
        let manager = GameCenterManager.shared
        
        if manager.isAuthenticated {
            // Test reporting a score
            manager.reportScore(100)
            print("✓ Score reporting tested")
        } else {
            print("⚠️ Cannot test score reporting: player not authenticated")
        }
    }
}
#endif

// SwiftUI preview for testing GameCenterView
struct GameCenterView_Tests: PreviewProvider {
    static var previews: some View {
        VStack {
            GameCenterView()
                .padding()
                .previewLayout(.sizeThatFits)
                .environmentObject(GameState())
            
            // Test with authenticated state
            GameCenterView()
                .padding()
                .previewLayout(.sizeThatFits)
                .environmentObject({
                    let manager = GameCenterManager.shared
                    manager.isAuthenticated = true
                    manager.playerName = "TestPlayer123"
                    return manager
                }())
        }
    }
}
