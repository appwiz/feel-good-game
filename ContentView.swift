import SwiftUI

struct ContentView: View {
    @EnvironmentObject var gameState: GameState
    @State private var showSettings = false
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        ZStack {
            if showSettings {
                SettingsView(isPresented: $showSettings)
            } else {
                GameView(showSettings: $showSettings)
            }
        }
        .onAppear {
            // Ensure we load the latest state from iCloud when the app starts
            gameState.loadState()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background || newPhase == .inactive {
                // Save state when the app goes to background
                gameState.saveState()
            } else if newPhase == .active {
                // Refresh state when app becomes active again
                gameState.loadState()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(GameState())
    }
}
