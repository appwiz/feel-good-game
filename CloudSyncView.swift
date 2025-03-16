import SwiftUI
import Combine

struct CloudSyncView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showSyncDetails = false
    @State private var lastSyncTime: String = "Never"
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation {
                    showSyncDetails.toggle()
                }
            }) {
                HStack {
                    Image(systemName: gameState.isSyncing ? "arrow.triangle.2.circlepath.circle.fill" : "icloud")
                        .foregroundColor(.blue)
                        .rotationEffect(gameState.isSyncing ? .degrees(360) : .degrees(0))
                        .animation(
                            gameState.isSyncing ? 
                                Animation.linear(duration: 1).repeatForever(autoreverses: false) : 
                                .default, 
                            value: gameState.isSyncing
                        )
                    
                    Text(gameState.isSyncing ? "Syncing..." : "iCloud Sync")
                        .font(.subheadline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: showSyncDetails ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                        .font(.caption)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            .buttonStyle(PlainButtonStyle())
            
            if showSyncDetails {
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Last synced:")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(lastSyncTime)
                            .font(.caption)
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        // Force a sync
                        gameState.saveState()
                        updateLastSyncTime()
                    }) {
                        Text("Sync Now")
                            .font(.caption)
                            .padding(.vertical, 4)
                            .padding(.horizontal, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(4)
                    }
                    .disabled(gameState.isSyncing)
                    .opacity(gameState.isSyncing ? 0.5 : 1.0)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .transition(.opacity)
            }
        }
        .onAppear {
            updateLastSyncTime()
        }
        .onChange(of: gameState.isSyncing) { isSyncing in
            if !isSyncing {
                // Update last sync time when syncing completes
                updateLastSyncTime()
            }
        }
    }
    
    private func updateLastSyncTime() {
        if let lastSync = CloudKitManager.shared.getLastSyncTime() {
            lastSyncTime = dateFormatter.string(from: lastSync)
        } else {
            lastSyncTime = "Never"
        }
    }
}

struct CloudSyncView_Previews: PreviewProvider {
    static var previews: some View {
        CloudSyncView()
            .environmentObject(GameState())
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
