import SwiftUI

struct FallingEmoji: Identifiable {
    let id = UUID()
    var position: CGPoint
    var opacity: Double = 1.0
    var scale: CGFloat = 1.0
    var velocity: CGPoint  // Now using 2D vector for velocity
    var rotation: CGFloat = 0  // Added rotation
    var angularVelocity: CGFloat  // Added spin
    
    // Physics constants
    static let gravity: CGFloat = 980.0  // pixels per second squared
    static let airResistance: CGFloat = 0.97  // dampening factor
    static let turbulence: CGFloat = 50.0  // wind effect strength
}

struct FallingEmojisView: View {
    let emoji: String
    @State private var emojis: [FallingEmoji] = []
    private let timer = Timer.publish(every: 1/60, on: .main, in: .common).autoconnect()
    let onReset = NotificationCenter.default.publisher(for: Notification.Name("ResetEmojis"))
    
    init(emoji: String = "⚡️") {
        self.emoji = emoji
    }
    
    var body: some View {
        GeometryReader { geometry in
            Canvas { context, size in
                for emoji in emojis {
                    var transform = CGAffineTransform.identity
                        .translatedBy(x: emoji.position.x, y: emoji.position.y)
                        .rotated(by: emoji.rotation)
                        .scaledBy(x: emoji.scale, y: emoji.scale)
                    
                    context.opacity = emoji.opacity
                    context.transform = transform
                    
                    let text = Text(self.emoji).font(.system(size: 24))
                    context.draw(text, at: .zero)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .onAppear {
            createEmojis()
        }
        .onReceive(timer) { time in
            updateEmojis(deltaTime: 1/60)
        }
        .onReceive(onReset) { _ in
            createEmojis()
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func createEmojis() {
        let screenSize = NSScreen.main?.frame ?? .zero
        let startY: CGFloat = -50
        
        emojis = (0..<15).map { _ in
            FallingEmoji(
                position: CGPoint(
                    x: CGFloat.random(in: 0...screenSize.width),
                    y: startY
                ),
                velocity: CGPoint(
                    x: CGFloat.random(in: -100...100),  // Initial horizontal velocity
                    y: CGFloat.random(in: 0...50)       // Initial vertical velocity
                ),
                angularVelocity: CGFloat.random(in: -2...2)  // Initial spin
            )
        }
    }
    
    private func updateEmojis(deltaTime: CGFloat) {
        let screenHeight = NSScreen.main?.frame.height ?? 1000
        
        for i in emojis.indices {
            // Apply gravity
            emojis[i].velocity.y += FallingEmoji.gravity * deltaTime
            
            // Apply air resistance
            emojis[i].velocity.x *= FallingEmoji.airResistance
            emojis[i].velocity.y *= FallingEmoji.airResistance
            
            // Add some turbulence
            emojis[i].velocity.x += CGFloat.random(in: -FallingEmoji.turbulence...FallingEmoji.turbulence) * deltaTime
            
            // Update position
            emojis[i].position.x += emojis[i].velocity.x * deltaTime
            emojis[i].position.y += emojis[i].velocity.y * deltaTime
            
            // Update rotation
            emojis[i].rotation += emojis[i].angularVelocity * deltaTime
            
            // Fade out and shrink when below screen
            if emojis[i].position.y > screenHeight {
                emojis[i].opacity -= 0.03
                emojis[i].scale = max(0.2, emojis[i].scale - 0.02)
            }
        }
        
        // Remove emojis that have faded out
        emojis.removeAll { $0.opacity <= 0 }
    }
} 