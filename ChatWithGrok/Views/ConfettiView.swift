import SwiftUI

struct ConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    let duration: TimeInterval
    let emojis: [String]
    
    init(duration: TimeInterval = 1.0, emojis: [String] = ["🎉", "✨", "💫", "🎊"]) {
        self.duration = duration
        self.emojis = emojis
    }
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for particle in particles {
                    let resolved = context.resolve(Text(particle.emoji).font(.system(size: particle.size)))
                    let x = particle.origin.x + particle.velocity.dx * particle.age
                    let y = particle.origin.y + particle.velocity.dy * particle.age + 0.5 * 600 * pow(particle.age, 2)
                    let position = CGPoint(x: x, y: y)
                    context.translateBy(x: position.x, y: position.y)
                    context.rotate(by: .degrees(particle.rotation * particle.age))
                    context.draw(resolved, at: .zero, anchor: .center)
                    context.rotate(by: .degrees(-particle.rotation * particle.age))
                    context.translateBy(x: -position.x, y: -position.y)
                }
            }
            .onChange(of: timeline.date) { _, _ in
                updateParticles()
            }
            .onAppear {
                spawnParticles()
            }
            .ignoresSafeArea()
        }
        .allowsHitTesting(false)
    }
    
    private func spawnParticles() {
        particles = (0..<36).map { _ in
            ConfettiParticle(
                emoji: emojis.randomElement() ?? "🎉",
                origin: CGPoint(x: .random(in: 0...UIScreen.main.bounds.width), y: -40),
                velocity: CGVector(dx: .random(in: -80...80), dy: .random(in: 80...160)),
                rotation: .random(in: -180...180),
                size: .random(in: 14...22),
                lifetime: duration
            )
        }
    }
    
    private func updateParticles() {
        let now = Date().timeIntervalSinceReferenceDate
        particles = particles.compactMap { particle in
            var updated = particle
            if updated.birth == 0 { updated.birth = now }
            updated.age = now - updated.birth
            return updated.age <= updated.lifetime ? updated : nil
        }
    }
}

private struct ConfettiParticle: Identifiable {
    let id = UUID()
    let emoji: String
    let origin: CGPoint
    let velocity: CGVector
    let rotation: Double
    let size: CGFloat
    let lifetime: TimeInterval
    var birth: TimeInterval = 0
    var age: TimeInterval = 0
}


