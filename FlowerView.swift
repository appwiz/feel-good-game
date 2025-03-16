import SwiftUI

struct FlowerView: View {
    let position: CGPoint
    let size: CGSize
    let onAnimationComplete: () -> Void
    
    @State private var opacity: Double = AnimationManager.flowerInitialOpacity
    @State private var scale: CGFloat = AnimationManager.flowerInitialScale
    @State private var rotation: Double = 0
    
    // Use a custom flower image if available, otherwise use system image
    private var flowerImage: some View {
        Group {
            #if os(iOS) || os(macOS)
            if let _ = Bundle.main.path(forResource: "flower1", ofType: "png", inDirectory: "Assets.xcassets/Flowers.imageset") {
                Image("Flowers")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Image(systemName: "flower")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .foregroundColor(.pink)
            }
            #else
            Image(systemName: "flower")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.pink)
            #endif
        }
    }
    
    var body: some View {
        flowerImage
            .frame(width: size.width * 0.6, height: size.height * 0.6)
            .position(position)
            .opacity(opacity)
            .scaleEffect(scale)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                // Appear animation
                withAnimation(AnimationManager.flowerAppearCurve) {
                    opacity = AnimationManager.flowerFinalOpacity
                    scale = AnimationManager.flowerFinalScale
                    rotation = AnimationManager.flowerRotation
                }
                
                // Disappear after 1.5 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation(AnimationManager.flowerDisappearCurve) {
                        opacity = AnimationManager.rectangleDisappearOpacity
                        scale = AnimationManager.flowerDisappearScale
                    }
                    
                    // Notify when animation is complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + AnimationManager.flowerDisappearDuration) {
                        onAnimationComplete()
                    }
                }
            }
    }
}
