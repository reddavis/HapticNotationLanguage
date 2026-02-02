import Foundation
import CoreHaptics

struct Interpreter {
    let nodes: [Node]

    // MARK: Initialization

    init(nodes: [Node]) {
        self.nodes = nodes
    }

    // MARK: API

    func interpret() throws -> HapticPattern {
        var definitions: [String : Node] = [:]
        var events: [CHHapticEvent] = []
        var curves: [CHHapticParameterCurve] = []
        var time: TimeInterval = 0

        for node in nodes {
            switch node {
            case .define(let name, let node):
                definitions[name] = node

            case .continuous, .loop, .ramp, .reference, .sequence, .transient:
                let result = try interpretNode(
                    node,
                    startTime: time,
                    definitions: definitions
                )
                events.append(contentsOf: result.events)
                curves.append(contentsOf: result.curves)
                time = result.endTime

            case .rest(let duration):
                time += duration ?? 0.1
            }
        }

        return HapticPattern(events: events, parameterCurves: curves)
    }

    private func interpretNode(
        _ node: Node,
        startTime: TimeInterval,
        definitions: [String : Node]
    ) throws -> InterpretationResult {
        switch node {
        case .continuous(let duration, let intensity, let sharpness, let adsr):
            let event = CHHapticEvent(
                eventType: .hapticContinuous,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: intensity.value),
                    .init(parameterID: .hapticSharpness, value: sharpness.value),
                ],
                relativeTime: startTime,
                duration: duration,
            )

            var curve: CHHapticParameterCurve?
            if let adsr {
                let attackTime = duration * adsr.attack
                let decayTime = duration * adsr.decay
                let releaseTime = duration * adsr.release

                curve = CHHapticParameterCurve(
                    parameterID: .hapticIntensityControl,
                    controlPoints: [
                        .init(relativeTime: 0, value: 0),
                        .init(relativeTime: attackTime, value: 1.0),
                        .init(relativeTime: decayTime, value: Float(adsr.sustain)),
                        .init(relativeTime: releaseTime, value: Float(adsr.sustain)),
                        // Need to return to 1, otherwise future haptics don't seem to work.
                        .init(relativeTime: duration, value: 1),
                    ],
                    relativeTime: startTime
                )
            }
            return .init(
                events: [event],
                curves: [curve].compactMap { $0 },
                endTime: startTime + duration,
            )

        case .loop(let count, let interval, let body):
            let iterationLength = Double(body.count) * interval
            var events: [CHHapticEvent] = []

            for iteration in 0..<count {
                let iterationStart = startTime + Double(iteration) * iterationLength

                for (index, node) in body.enumerated() {
                    if case .rest = node { continue }
                    let result = try interpretNode(
                        node,
                        startTime: iterationStart + Double(index) * interval,
                        definitions: definitions
                    )
                    events.append(contentsOf: result.events)
                }
            }

            return .init(
                events: events,
                curves: [],
                endTime: startTime + Double(count) * iterationLength,
            )

        case .ramp(let duration, let intensity, let sharpness, let interval, _):
            var events: [CHHapticEvent] = []
            var currentTime: TimeInterval = 0

            while currentTime < duration {
                let progress = currentTime / duration

                let intensity = intensity?.interpolate(at: progress) ?? 0.5
                let sharpness = sharpness?.interpolate(at: progress) ?? 0.5
                let interval = interval?.interpolate(at: progress) ?? 0.1

                let event = CHHapticEvent(
                    eventType: .hapticTransient,
                    parameters: [
                        .init(parameterID: .hapticIntensity, value: Float(intensity)),
                        .init(parameterID: .hapticSharpness, value: Float(sharpness)),
                    ],
                    relativeTime: startTime + currentTime,
                )
                events.append(event)

                currentTime += interval
            }

            let finalEvent = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: Float(intensity?.to.value ?? 0.5)),
                    .init(parameterID: .hapticSharpness, value: Float(sharpness?.to.value ?? 0.5)),
                ],
                relativeTime: startTime + duration,
            )
            events.append(finalEvent)

            return .init(
                events: events,
                curves: [],
                endTime: startTime + duration,
            )

        case .reference(let name):
            guard let referencedNode = definitions[name] else {
                throw InterpreterError.definitionMissing(name)
            }
            return try interpretNode(
                referencedNode,
                startTime: startTime,
                definitions: definitions
            )

        case .sequence(let interval, let body):
            let events = try body.enumerated().flatMap { index, node in
                try interpretNode(
                    node,
                    startTime: startTime + Double(index) * interval,
                    definitions: definitions
                ).events
            }
            return .init(
                events: events,
                curves: [],
                endTime: startTime + Double(body.count - 1) * interval,
            )

        case .transient(let intensity, let sharpness):
            let event = CHHapticEvent(
                eventType: .hapticTransient,
                parameters: [
                    .init(parameterID: .hapticIntensity, value: intensity.value),
                    .init(parameterID: .hapticSharpness, value: sharpness.value),
                ],
                relativeTime: startTime,
            )
            return .init(
                events: [event],
                curves: [],
                endTime: startTime,
            )

        default:
            return .init(events: [], curves: [], endTime: startTime)
        }
    }

    // MARK: Helper

    private func interpolate<T: FloatingPoint>(from: T, to: T, progress: T) -> T {
        from + (to - from) * progress
    }
}

fileprivate struct InterpretationResult {
    let events: [CHHapticEvent]
    let curves: [CHHapticParameterCurve]
    let endTime: TimeInterval
}

enum InterpreterError: Error {
    case definitionMissing(String)
}

struct HapticPattern {
    let events: [CHHapticEvent]
    let parameterCurves: [CHHapticParameterCurve]

    func chPattern() throws -> CHHapticPattern {
        try CHHapticPattern(events: events, parameterCurves: parameterCurves)
    }
}

extension CHHapticPattern {
    convenience init(_ pattern: HapticPattern) throws {
        try self.init(events: pattern.events, parameterCurves: pattern.parameterCurves)
    }
}

// MARK: Transition

extension Transition where T: FloatingPoint {
    fileprivate func interpolate(at progress: T) -> T {
        from + (to - from) * progress
    }
}

extension Transition where T == Intensity {
    fileprivate func interpolate(at progress: Double) -> Double {
        Double(from.value) + Double(to.value - from.value) * progress
    }
}

extension Transition where T == Sharpness {
    fileprivate func interpolate(at progress: Double) -> Double {
        Double(from.value) + Double(to.value - from.value) * progress
    }
}
