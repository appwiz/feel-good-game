import SwiftUI

struct RectangleView: View {
    let rectangle: GameRectangle
    let onTap: () -> Void
    
    @State private var opacity: Double = AnimationManager.rectangleInitialOpacity
    @State private var scale: CGFloat = AnimationManager.rectangleInitialScale
    
    var body: some View {
        rectangleContent
            .frame(width: rectangle.frame.width, height: rectangle.frame.height)
            .position(x: rectangle.frame.midX, y: rectangle.frame.midY)
            .opacity(opacity)
            .scaleEffect(scale)
            .onAppear {
                withAnimation(AnimationManager.rectangleAppearCurve) {
                    opacity = AnimationManager.rectangleFinalOpacity
                    scale = AnimationManager.rectangleFinalScale
                }
            }
            .onTapGesture {
                withAnimation(AnimationManager.rectangleDisappearCurve) {
                    opacity = AnimationManager.rectangleDisappearOpacity
                    scale = AnimationManager.rectangleDisappearScale
                }
                onTap()
            }
    }
    
    @ViewBuilder
    private var rectangleContent: some View {
        switch rectangle.colorType {
        case 0: // Solid color
            rectangle.colors[0]
                .cornerRadius(12)
                .shadow(radius: 5)
        
        case 1: // Linear gradient
            LinearGradient(
                gradient: Gradient(colors: rectangle.colors),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .cornerRadius(12)
            .shadow(radius: 5)
            
        case 2: // Radial gradient
            RadialGradient(
                gradient: Gradient(colors: rectangle.colors),
                center: .center,
                startRadius: 0,
                endRadius: min(rectangle.frame.width, rectangle.frame.height) / 2
            )
            .cornerRadius(12)
            .shadow(radius: 5)
            
        default:
            rectangle.colors[0]
                .cornerRadius(12)
                .shadow(radius: 5)
        }
    }
}
