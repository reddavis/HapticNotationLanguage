import Foundation

indirect enum Node: Equatable {
    case transient(
        intensity: Intensity,
        sharpness: Sharpness,
    )

    case continuous(
        duration: TimeInterval,
        intensity: Intensity,
        sharpness: Sharpness,
        adsr: ADSR?,
    )

    case rest(TimeInterval?)

    case sequence(
        interval: TimeInterval,
        body: [Node],
    )

    case loop(
        count: Int,
        interval: TimeInterval,
        body: [Node],
    )

    case ramp(
        duration: TimeInterval,
        intensity: Transition<Intensity>?,
        sharpness: Transition<Sharpness>?,
        interval: Transition<TimeInterval>?,
    )

    case define(
        name: String,
        body: Node,
    )

    case reference(String)
}

struct Transition<T> {
    let from: T
    let to: T
}

extension Transition: Equatable where T: Equatable {}

enum Intensity: Equatable {
    case silent
    case soft
    case medium
    case loud
    case max
    case value(Float)

    var value: Float {
        switch self {
        case .silent:
            return 0.0
        case .soft:
            return 0.3
        case .medium:
            return 0.5
        case .loud:
            return 0.8
        case .max:
            return 1.0
        case .value(let value):
            return value
        }
    }
}

enum Sharpness: Equatable {
    case dull
    case balanced
    case sharp
    case value(Float)

    var value: Float {
        switch self {
        case .dull:
            return 0.0
        case .balanced:
            return 0.5
        case .sharp:
            return 1.0
        case .value(let value):
            return value
        }
    }
}

struct ADSR: Equatable {
    let attack: Double
    let decay: Double
    let sustain: Double
    let release: Double
}
