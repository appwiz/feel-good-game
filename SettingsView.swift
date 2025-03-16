import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var gameState: GameState
    @Binding var isPresented: Bool
    
    // For animation
    @State private var sliderValue: Double
    
    init(isPresented: Binding<Bool>) {
        self._isPresented = isPresented
        self._sliderValue = State(initialValue: isPresented.wrappedValue ? 0 : 1)
    }
    
    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    // Close settings when tapping outside
                    withAnimation {
                        gameState.saveState()
                        isPresented = false
                    }
                }
            
            // Settings panel
            VStack(spacing: 20) {
                // Header
                Text("Game Settings")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .padding(.top)
                
                // Divider
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(.blue.opacity(0.5))
                    .padding(.horizontal)
                
                // Interval settings
                VStack(alignment: .leading, spacing: 10) {
                    Text("Rectangle Appearance Interval")
                        .font(.headline)
                    
                    Text("\(String(format: "%.1f", gameState.rectangleAppearanceInterval)) seconds")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        Text("\(gameState.minInterval, specifier: "%.1f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(
                            value: $gameState.rectangleAppearanceInterval,
                            in: gameState.minInterval...gameState.maxInterval,
                            step: 0.1
                        )
                        .accentColor(.blue)
                        
                        Text("\(gameState.maxInterval, specifier: "%.1f")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 30)
                
                // Game stats
                VStack(alignment: .leading, spacing: 15) {
                    Text("Game Statistics")
                        .font(.headline)
                    
                    HStack {
                        Image(systemName: "hand.tap")
                            .foregroundColor(.blue)
                        Text("Tapped Score: ")
                            .foregroundColor(.secondary)
                        Text("\(gameState.score)")
                            .bold()
                    }
                    
                    HStack {
                        Image(systemName: "flower")
                            .foregroundColor(.pink)
                        Text("Flowers Seen: ")
                            .foregroundColor(.secondary)
                        Text("\(gameState.flowersSeen)")
                            .bold()
                    }
                    
                    // iCloud sync status
                    CloudSyncView()
                    
                    // Game Center status
                    GameCenterView()
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 10)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal, 20)
                
                Spacer()
                
                // Buttons
                HStack(spacing: 20) {
                    Button(action: {
                        withAnimation {
                            gameState.resetState()
                        }
                    }) {
                        Text("Reset Game")
                            .padding()
                            .frame(minWidth: 120)
                            .background(Color.red.opacity(0.8))
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                    
                    Button(action: {
                        withAnimation {
                            gameState.saveState()
                            isPresented = false
                        }
                    }) {
                        Text("Save & Return")
                            .padding()
                            .frame(minWidth: 120)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                }
                .padding(.bottom)
            }
            .frame(minWidth: 350, maxWidth: 450, minHeight: 450, maxHeight: 550)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
                    .shadow(radius: 15)
            )
            .scaleEffect(sliderValue)
            .opacity(sliderValue)
            .onAppear {
                withAnimation(.spring()) {
                    sliderValue = 1
                }
                // Save state when settings are opened
                gameState.saveState()
            }
            .onDisappear {
                sliderValue = 0
            }
        }
    }
}
