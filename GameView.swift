import SwiftUI
import AVFoundation
import GameKit

struct GameView: View {
    @EnvironmentObject var gameState: GameState
    @Binding var showSettings: Bool
    @ObservedObject private var gameCenterManager = GameCenterManager.shared
    
    @StateObject private var rectangleGenerator = RectangleGenerator()
    @State private var audioPlayer: AVAudioPlayer?
    @State private var viewSize: CGSize = .zero
    @State private var showAchievementBanner = false
    @State private var achievementMessage = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                BackgroundView()
                
                // Game elements
                ZStack {
                    // Current rectangle
                    if let rectangle = rectangleGenerator.currentRectangle {
                        RectangleView(rectangle: rectangle) {
                            handleSuccessfulTap(at: CGPoint(
                                x: rectangle.frame.midX,
                                y: rectangle.frame.midY
                            ))
                        }
                    }
                    
                    // Flower (shown occasionally after a tap)
                    if rectangleGenerator.showFlower, 
                       let rectangle = rectangleGenerator.currentRectangle {
                        FlowerView(
                            position: CGPoint(x: rectangle.frame.midX, y: rectangle.frame.midY),
                            size: CGSize(width: rectangle.frame.width, height: rectangle.frame.height)
                        ) {
                            // Animation complete
                        }
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture { location in
                    // Handle tap anywhere on the game area
                    if rectangleGenerator.handleTap(at: location) {
                        handleSuccessfulTap(at: location)
                    }
                }
                
                // UI overlay
                VStack {
                    HStack {
                        Button(action: {
                            rectangleGenerator.stopGenerating()
                            gameState.pauseGame()
                            // In a real app, this would exit the game
                            // For now, we'll just save state
                        }) {
                            Text("Pause")
                                .font(.headline)
                                .padding()
                                .frame(minWidth: 100)
                                .background(Color.blue.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            rectangleGenerator.stopGenerating()
                            showSettings = true
                        }) {
                            Text("Settings")
                                .font(.headline)
                                .padding()
                                .frame(minWidth: 100)
                                .background(Color.green.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                    }
                    .padding()
                    
                    Spacer()
                    
                    // Score display
                    VStack {
                        HStack {
                            Image(systemName: "hand.tap")
                                .font(.title)
                            Text("Tapped: \(gameState.score)")
                                .font(.title)
                                .bold()
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(15)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        
                        HStack {
                            Image(systemName: "flower")
                                .font(.title2)
                                .foregroundColor(.pink)
                            Text("Flowers: \(gameState.flowersSeen)")
                                .font(.title2)
                                .bold()
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(15)
                        .shadow(radius: 2)
                        .padding(.horizontal)
                        
                        // Game Center player info (when authenticated)
                        if gameCenterManager.isAuthenticated {
                            HStack {
                                Image(systemName: "gamecontroller.fill")
                                    .foregroundColor(.yellow)
                                Text(gameCenterManager.playerName)
                                    .font(.headline)
                                
                                Spacer()
                                
                                Button(action: {
                                    gameCenterManager.showAchievements()
                                }) {
                                    Image(systemName: "trophy.fill")
                                        .foregroundColor(.yellow)
                                        .font(.title3)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .padding(.horizontal, 4)
                                
                                Button(action: {
                                    gameCenterManager.showLeaderboards()
                                }) {
                                    Image(systemName: "list.number")
                                        .foregroundColor(.blue)
                                        .font(.title3)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                            .padding()
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(15)
                            .shadow(radius: 2)
                            .padding(.horizontal)
                        }
                        
                        .padding(.bottom)
                    }
                }
            }
            .onAppear {
                viewSize = geometry.size
                setupAudio()
                startGame()
                
                // Authenticate with Game Center
                if !gameCenterManager.isAuthenticated {
                    gameCenterManager.authenticatePlayer()
                }
            }
            .onChange(of: gameState.rectangleAppearanceInterval) { newValue in
                rectangleGenerator.updateInterval(to: newValue)
            }
            .onChange(of: showSettings) { isShowing in
                if !isShowing {
                    // Resume game when returning from settings
                    startGame()
                }
            }
            
            // Achievement banner
            if showAchievementBanner {
                VStack {
                    Spacer()
                    
                    HStack {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                            .font(.title)
                        
                        Text(achievementMessage)
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.black.opacity(0.8))
                    )
                    .padding(.bottom, 100)
                    .transition(.move(edge: .bottom))
                    .animation(.easeInOut, value: showAchievementBanner)
                }
            }
        }
    }
    
    // Start or resume the game
    private func startGame() {
        gameState.resumeGame()
        rectangleGenerator.startGenerating(
            interval: gameState.rectangleAppearanceInterval,
            in: viewSize
        )
    }
    
    // Handle a successful tap on a rectangle
    private func handleSuccessfulTap(at location: CGPoint) {
        // Increment score
        gameState.score += 1
        
        // Check for achievement milestones
        checkAchievementMilestones()
        
        // Check if flower was shown
        if rectangleGenerator.showFlower {
            gameState.incrementFlowerSeen()
            checkFlowerAchievementMilestones()
        }
    }
    
    // Check for achievement milestones
    private func checkAchievementMilestones() {
        let achievementThresholds = [100, 500, 1000, 5000, 10000, 50000, 100000, 500000]
        
        // Check if we just crossed a threshold
        for threshold in achievementThresholds {
            if gameState.score == threshold {
                showAchievementNotification("Achievement Unlocked: \(threshold) Taps!")
                break
            }
        }
    }
    
    // Check for flower achievement milestones
    private func checkFlowerAchievementMilestones() {
        let flowerThresholds = [10, 50, 100]
        
        // Check if we just crossed a threshold
        for threshold in flowerThresholds {
            if gameState.flowersSeen == threshold {
                showAchievementNotification("Achievement Unlocked: \(threshold) Flowers!")
                break
            }
        }
    }
    
    // Show achievement notification
    private func showAchievementNotification(_ message: String) {
        achievementMessage = message
        
        withAnimation {
            showAchievementBanner = true
        }
        
        // Hide banner after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                self.showAchievementBanner = false
            }
        }
    }
    
    // Setup audio player
    private func setupAudio() {
        // SoundManager is initialized as a singleton
        // No need to do anything here
    }
    
    // Play the tap sound
    private func playTapSound() {
        // Sound is now handled directly in the RectangleGenerator
        // to ensure proper synchronization with flower appearance
    }
}

// GameCenter view controller representable for SwiftUI
struct GameCenterViewControllerRepresentable: UIViewControllerRepresentable {
    var state: GKGameCenterViewController.State
    
    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let viewController = GKGameCenterViewController(state: state)
        viewController.gameCenterDelegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator()
    }
    
    class Coordinator: NSObject, GKGameCenterControllerDelegate {
        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            gameCenterViewController.dismiss(animated: true)
        }
    }
}
