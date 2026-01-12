import ComposableArchitecture
import CoreHaptics
import HapticNotationLanguage

struct DetailsProvider: Sendable {
    var play: @Sendable (HNLExample) async throws -> Void
}

// MARK: Main

extension DetailsProvider {
    static var main: Self {
        let player = HapticsPlayer()
        return .init(
            play: {
                let pattern = try HapticNotationLanguage.parse($0.notation)
                try await player.play(pattern)
            },
        )
    }
}

// MARK: Mock

extension DetailsProvider {
    static var mock: Self {
        .init(
            play: { _ in },
        )
    }
}

// MARK: Dependency

extension DetailsProvider: DependencyKey {
    static let liveValue: Self = .main
    static let previewValue: Self = .mock
    static let testValue: Self = .mock
}

extension DependencyValues {
    var detailsProvider: DetailsProvider {
        get { self[DetailsProvider.self] }
        set { self[DetailsProvider.self] = newValue }
    }
}

// MARK: Haptics Player

actor HapticsPlayer {
    private var engine: CHHapticEngine?
    private var player: (any CHHapticPatternPlayer)?

    func play(_ pattern: CHHapticPattern) throws {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
            throw HapticsPlayerError.hapticsNotSupported
        }
        
        let engine = try CHHapticEngine()
        engine.playsHapticsOnly = true
        try engine.start()
        self.engine = engine

        let player = try engine.makePlayer(with: pattern)
        self.player = player
        try player.start(atTime: CHHapticTimeImmediate)
    }
}

enum HapticsPlayerError: Error {
    case hapticsNotSupported
}
