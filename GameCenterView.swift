import SwiftUI
import GameKit

struct GameCenterView: View {
    @ObservedObject private var gameCenterManager = GameCenterManager.shared
    @State private var showingAuthAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: gameCenterManager.isAuthenticated ? "gamecontroller.fill" : "gamecontroller")
                    .foregroundColor(gameCenterManager.isAuthenticated ? .green : .gray)
                    .font(.title3)
                
                VStack(alignment: .leading) {
                    Text(gameCenterManager.isAuthenticated ? "Game Center: Connected" : "Game Center: Not Connected")
                        .font(.subheadline)
                        .foregroundColor(gameCenterManager.isAuthenticated ? .primary : .secondary)
                    
                    if gameCenterManager.isAuthenticated {
                        Text("Player: \(gameCenterManager.playerName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if gameCenterManager.isAuthenticating {
                        Text("Connecting to Game Center...")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if let error = gameCenterManager.lastError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                if gameCenterManager.isAuthenticated {
                    Button(action: {
                        gameCenterManager.showAchievements()
                    }) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(.yellow)
                            .font(.title3)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.horizontal, 8)
                    
                    Button(action: {
                        gameCenterManager.showLeaderboards()
                    }) {
                        Image(systemName: "list.number")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                    .buttonStyle(PlainButtonStyle())
                } else {
                    Button(action: {
                        showingAuthAlert = true
                    }) {
                        Text("Sign In")
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .alert(isPresented: $showingAuthAlert) {
                Alert(
                    title: Text("Game Center Authentication"),
                    message: Text("Please sign in to Game Center in your device settings to track achievements and leaderboards."),
                    primaryButton: .default(Text("Try Again")) {
                        gameCenterManager.authenticatePlayer()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
}

struct GameCenterView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            // Preview with authenticated state
            GameCenterView()
                .environmentObject({
                    let manager = GameCenterManager.shared
                    manager.isAuthenticated = true
                    manager.playerName = "TestPlayer123"
                    return manager
                }())
                .padding()
                .previewLayout(.sizeThatFits)
            
            // Preview with unauthenticated state
            GameCenterView()
                .environmentObject({
                    let manager = GameCenterManager.shared
                    manager.isAuthenticated = false
                    manager.lastError = "Game Center is not available"
                    return manager
                }())
                .padding()
                .previewLayout(.sizeThatFits)
            
            // Preview with authenticating state
            GameCenterView()
                .environmentObject({
                    let manager = GameCenterManager.shared
                    manager.isAuthenticated = false
                    manager.isAuthenticating = true
                    return manager
                }())
                .padding()
                .previewLayout(.sizeThatFits)
        }
    }
}
