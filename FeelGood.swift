import SwiftUI
import CloudKit
import GameKit
import AVFoundation

@main
struct FeelGoodApp: App {
    // Create a shared game state
    @StateObject private var gameState = GameState()
    
    init() {
        // Configure audio session
        setupAudioSession()
        
        #if DEBUG
        // Run tests in debug builds
        if CommandLine.arguments.contains("--test-icloud") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                iCloudSyncTests.runTests()
            }
        }
        
        if CommandLine.arguments.contains("--test-gamecenter") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                GameCenterTests.runTests()
            }
        }
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(gameState)
                .onAppear {
                    // Request iCloud permissions if needed
                    requestiCloudPermissions()
                    
                    // Preload sound manager
                    _ = SoundManager.shared
                    
                    // Setup iCloud sync notification observers
                    setupCloudKitNotifications()
                }
        }
    }
    
    // Configure audio session for the app
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error.localizedDescription)")
        }
    }
    
    // Request iCloud permissions
    private func requestiCloudPermissions() {
        CKContainer.default().accountStatus { status, error in
            if status == .available {
                print("iCloud is available")
                // Verify container access
                self.verifyiCloudContainerAccess()
            } else {
                print("iCloud is not available: \(status.rawValue)")
                if let error = error {
                    print("iCloud error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Verify iCloud container access
    private func verifyiCloudContainerAccess() {
        let container = CKContainer.default()
        container.fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error fetching user record ID: \(error.localizedDescription)")
            } else if let recordID = recordID {
                print("Successfully accessed iCloud container with user ID: \(recordID.recordName)")
            }
        }
    }
    
    // Setup CloudKit notification observers
    private func setupCloudKitNotifications() {
        // Listen for CloudKit account changes
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name.CKAccountChanged,
            object: nil,
            queue: .main
        ) { _ in
            print("iCloud account changed, requesting permissions again")
            self.requestiCloudPermissions()
        }
        
        // Listen for remote notifications
        NotificationCenter.default.addObserver(
            forName: UIApplication.didReceiveRemoteNotificationNotification,
            object: nil,
            queue: .main
        ) { notification in
            if let userInfo = notification.userInfo as? [String: Any],
               let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo) {
                print("Received CloudKit notification: \(cloudKitNotification)")
                
                // Trigger a sync when we receive a CloudKit notification
                if cloudKitNotification.notificationType == .database {
                    print("Database changed, refreshing data")
                    // Refresh game state
                    gameState.loadState()
                }
            }
        }
    }
}
