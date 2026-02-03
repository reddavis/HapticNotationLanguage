import CoreHaptics
import Testing
@testable import HapticNotationLanguage

struct InterpreterTests {
    @Test func comments() throws {
        let pattern = try parse(Fixture.comments)

        #expect(pattern.events.count == 1)

        #expect(pattern.events[0].relativeTime == 0)
        #expect(pattern.events[0].type == .hapticTransient)
        #expect(pattern.events[0].intensity == 0.8)
        #expect(pattern.events[0].sharpness == 1.0)
    }

    @Test func transientWithAliases() throws {
        let pattern = try parse(Fixture.transientWithAliases)

        #expect(pattern.events.count == 3)

        #expect(pattern.events[0].relativeTime == 0)
        #expect(pattern.events[0].type == .hapticTransient)
        #expect(pattern.events[0].intensity == 0.8)
        #expect(pattern.events[0].sharpness == 1.0)

        #expect(pattern.events[1].relativeTime == 0.2)
        #expect(pattern.events[1].intensity == 0.3)
        #expect(pattern.events[1].sharpness == 0.0)

        #expect(pattern.events[2].relativeTime == 0.4)
        #expect(pattern.events[2].intensity == 0.5)
        #expect(pattern.events[2].sharpness == 0.5)
    }

    @Test func transientWithRawValues() throws {
        let pattern = try parse(Fixture.transientWithRawValues)

        #expect(pattern.events.count == 2)

        #expect(pattern.events[0].relativeTime == 0)
        #expect(pattern.events[0].intensity == 0.7)
        #expect(pattern.events[0].sharpness == 0.3)

        #expect(pattern.events[1].relativeTime == 0.2)
        #expect(pattern.events[1].intensity == 1.0)
        #expect(pattern.events[1].sharpness == 0.0)
    }

    @Test func transientMixed() throws {
        let pattern = try parse(Fixture.transientMixed)

        #expect(pattern.events.count == 2)

        #expect(pattern.events[0].intensity == 0.8)
        #expect(pattern.events[0].sharpness == 0.2)

        #expect(pattern.events[1].intensity == 0.5)
        #expect(pattern.events[1].sharpness == 1.0)
    }

    @Test func defineTransient() throws {
        let pattern = try parse(Fixture.defineTransient)

        #expect(pattern.events.count == 2)

        #expect(pattern.events[0].relativeTime == 0)
        #expect(pattern.events[0].intensity == 0.3)
        #expect(pattern.events[0].sharpness == 1.0)

        #expect(pattern.events[1].relativeTime == 0.2)
        #expect(pattern.events[1].intensity == 0.3)
        #expect(pattern.events[1].sharpness == 1.0)
    }

    @Test func sequenceBasic() throws {
        let pattern = try parse(Fixture.sequenceBasic)

        #expect(pattern.events.count == 3)

        #expect(pattern.events[0].relativeTime == 0)
        #expect(pattern.events[0].intensity == 0.8)
        #expect(pattern.events[0].sharpness == 1.0)

        #expect(pattern.events[1].relativeTime == 0.15)
        #expect(pattern.events[1].intensity == 0.5)
        #expect(pattern.events[1].sharpness == 0.5)

        #expect(pattern.events[2].relativeTime == 0.3)
        #expect(pattern.events[2].intensity == 0.3)
        #expect(pattern.events[2].sharpness == 0.0)
    }

    @Test func sequenceWithRests() throws {
        let pattern = try parse(Fixture.sequenceWithRests)

        #expect(pattern.events.count == 3)

        #expect(pattern.events[0].relativeTime == 0)
        #expect(pattern.events[1].relativeTime == 0.4)
        #expect(pattern.events[2].relativeTime == 0.8)
    }

    @Test func loopSimple() throws {
        let pattern = try parse(Fixture.loopSimple)

        #expect(pattern.events.count == 3)

        #expect(pattern.events[0].relativeTime == 0)
        #expect(pattern.events[1].relativeTime == 0.25)
        #expect(pattern.events[2].relativeTime == 0.5)
    }

    @Test func loopMultipleEvents() throws {
        let pattern = try parse(Fixture.loopMultipleEvents)

        #expect(pattern.events.count == 4)

        // Iteration 1
        #expect(pattern.events[0].relativeTime == 0)
        #expect(pattern.events[0].intensity == 0.8)
        #expect(pattern.events[1].relativeTime == 0.5)
        #expect(pattern.events[1].intensity == 0.3)

        // Iteration 2
        #expect(pattern.events[2].relativeTime == 1.0)
        #expect(pattern.events[2].intensity == 0.8)
        #expect(pattern.events[3].relativeTime == 1.5)
        #expect(pattern.events[3].intensity == 0.3)
    }

    @Test func continuousBasic() throws {
        let pattern = try parse(Fixture.continuousBasic)

        #expect(pattern.events.count == 1)
        #expect(pattern.events[0].type == .hapticContinuous)
        #expect(pattern.events[0].relativeTime == 0)
        #expect(pattern.events[0].duration == 1.0)
        #expect(pattern.events[0].intensity == 0.8)
        #expect(pattern.events[0].sharpness == 1.0)
    }

    @Test func continuousWithADSR() throws {
        let pattern = try parse(Fixture.continuousWithADSR)

        #expect(pattern.events.count == 1)
        #expect(pattern.events[0].type == .hapticContinuous)
        #expect(pattern.events[0].duration == 2.0)

        #expect(pattern.parameterCurves.count == 1)
        let curve = pattern.parameterCurves[0]
        #expect(curve.controlPoints.count == 5)
        #expect(curve.controlPoints[0].relativeTime == 0.0)
        #expect(curve.controlPoints[1].relativeTime == 0.1)
        #expect(curve.controlPoints[2].relativeTime == 0.3)
        #expect(curve.controlPoints[3].relativeTime == 2.0)
        #expect(curve.controlPoints[4].relativeTime == 2.0)

        // Ensure it returns back to normal
        #expect(curve.controlPoints[4].value == 1.0)
    }

    @Test func rampFull() throws {
        let pattern = try parse(Fixture.rampFull)

        #expect(pattern.events.count > 0)

        // First event
        #expect(pattern.events[0].relativeTime == 0)
        #expect(pattern.events[0].intensity == 0.3)
        #expect(pattern.events[0].sharpness == 0.2)

        // Last event
        let last = try #require(pattern.events.last)
        #expect(last.intensity == 1.0)
        #expect(last.sharpness == 0.8)
    }

    @Test func rampWithAliases() throws {
        let pattern = try parse(Fixture.rampWithAliases)

        #expect(pattern.events.count > 0)

        // First event
        #expect(pattern.events[0].intensity == 0.3)
        #expect(pattern.events[0].sharpness == 0.0)

        // Last event
        let last = try #require(pattern.events.last)
        #expect(last.intensity == 1.0)
        #expect(last.sharpness == 1.0)
    }

    @Test func complexPattern() throws {
        let pattern = try parse(Fixture.complexPattern)

        #expect(pattern.events.count == 7)

        #expect(pattern.events[0].type == .hapticTransient)
        expectTime(pattern.events[0].relativeTime, 0)

        #expect(pattern.events[1].type == .hapticTransient)
        expectTime(pattern.events[1].relativeTime, 0.3)

        #expect(pattern.events[2].type == .hapticTransient)
        expectTime(pattern.events[2].relativeTime, 0.45)

        #expect(pattern.events[3].type == .hapticContinuous)
        expectTime(pattern.events[3].relativeTime, 0.7)
        expectTime(pattern.events[3].duration, 0.4)

        #expect(pattern.parameterCurves.count == 1)

        #expect(pattern.events[4].type == .hapticTransient)
        expectTime(pattern.events[4].relativeTime, 1.2)

        #expect(pattern.events[5].type == .hapticTransient)
        expectTime(pattern.events[5].relativeTime, 1.32)

        #expect(pattern.events[6].type == .hapticTransient)
        expectTime(pattern.events[6].relativeTime, 1.44)
    }

    // MARK: Helpers

    private func parse(_ source: String) throws -> HapticPattern {
        var lexer = Lexer(source: source)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()
        let interpreter = Interpreter(nodes: nodes)
        return try interpreter.interpret()
    }

    private func expectTime(_ actual: TimeInterval, _ expected: TimeInterval) {
        #expect(abs(actual - expected) < 0.0001, "Expected \(expected), got \(actual)")
    }
}

extension CHHapticEvent {
    fileprivate var intensity: Float? {
        eventParameters.first { $0.parameterID == .hapticIntensity }?.value
    }

    fileprivate var sharpness: Float? {
        eventParameters.first { $0.parameterID == .hapticSharpness }?.value
    }
}

extension Double {
    fileprivate func rounded(toPlaces places: Int) -> Double {
        let multiplier = pow(10.0, Double(places))
        return (self * multiplier).rounded() / multiplier
    }
}
