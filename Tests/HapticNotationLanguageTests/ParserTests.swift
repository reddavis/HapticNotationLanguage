import Testing
@testable import HapticNotationLanguage

struct ParserTests {
    @Test func comments() throws {
        var lexer = Lexer(source: Fixture.comments)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .transient(intensity: .loud, sharpness: .sharp),
            ]
        )
    }

    @Test func transientWithAliases() throws {
        var lexer = Lexer(source: Fixture.transientWithAliases)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .transient(intensity: .loud, sharpness: .sharp),
                .rest(0.2),
                .transient(intensity: .soft, sharpness: .dull),
                .rest(0.2),
                .transient(intensity: .medium, sharpness: .balanced),
            ]
        )
    }

    @Test func transientWithRawValues() throws {
        var lexer = Lexer(source: Fixture.transientWithRawValues)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .transient(intensity: .value(0.7), sharpness: .value(0.3)),
                .rest(0.2),
                .transient(intensity: .value(1.0), sharpness: .value(0.0)),
            ]
        )
    }

    @Test func transientMixed() throws {
        var lexer = Lexer(source: Fixture.transientMixed)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .transient(intensity: .loud, sharpness: .value(0.2)),
                .rest(0.2),
                .transient(intensity: .value(0.5), sharpness: .sharp),
            ]
        )
    }

    @Test func defineTransient() throws {
        var lexer = Lexer(source: Fixture.defineTransient)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .define(
                    name: "tick",
                    body: .transient(intensity: .soft, sharpness: .sharp)
                ),
                .reference("tick"),
                .rest(0.2),
                .reference("tick"),
            ]
        )
    }

    @Test func defineContinuous() throws {
        var lexer = Lexer(source: Fixture.defineContinuous)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .define(
                    name: "buzz",
                    body: .continuous(
                        duration: 0.5,
                        intensity: .medium,
                        sharpness: .dull,
                        adsr: ADSR(attack: 0.1, decay: 0.2, sustain: 0.8, release: 1.0)
                    )
                ),
                .reference("buzz"),
            ]
        )
    }

    @Test func defineSequence() throws {
        var lexer = Lexer(source: Fixture.defineSequence)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .define(
                    name: "celebration",
                    body: .sequence(
                        interval: 0.1,
                        body: [
                            .transient(intensity: .medium, sharpness: .balanced),
                            .transient(intensity: .loud, sharpness: .sharp),
                            .transient(intensity: .max, sharpness: .sharp),
                        ]
                    )
                ),
                .reference("celebration"),
            ]
        )
    }

    @Test func defineLoop() throws {
        var lexer = Lexer(source: Fixture.defineLoop)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .define(
                    name: "heartbeat",
                    body: .loop(
                        count: 2,
                        interval: 0.3,
                        body: [
                            .transient(intensity: .loud, sharpness: .balanced),
                        ]
                    )
                ),
                .reference("heartbeat"),
            ]
        )
    }

    @Test func sequenceBasic() throws {
        var lexer = Lexer(source: Fixture.sequenceBasic)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .sequence(
                    interval: 0.15,
                    body: [
                        .transient(intensity: .loud, sharpness: .sharp),
                        .transient(intensity: .medium, sharpness: .balanced),
                        .transient(intensity: .soft, sharpness: .dull),
                    ]
                ),
            ]
        )
    }

    @Test func sequenceWithRests() throws {
        var lexer = Lexer(source: Fixture.sequenceWithRests)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .sequence(
                    interval: 0.2,
                    body: [
                        .transient(intensity: .max, sharpness: .sharp),
                        .rest(nil),
                        .transient(intensity: .loud, sharpness: .balanced),
                        .rest(nil),
                        .transient(intensity: .medium, sharpness: .dull),
                    ]
                ),
            ]
        )
    }

    @Test func loopSimple() throws {
        var lexer = Lexer(source: Fixture.loopSimple)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .loop(
                    count: 3,
                    interval: 0.25,
                    body: [
                        .transient(intensity: .soft, sharpness: .sharp),
                    ]
                ),
            ]
        )
    }

    @Test func loopMultipleEvents() throws {
        var lexer = Lexer(source: Fixture.loopMultipleEvents)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .loop(
                    count: 2,
                    interval: 0.5,
                    body: [
                        .transient(intensity: .loud, sharpness: .sharp),
                        .transient(intensity: .soft, sharpness: .dull),
                    ]
                ),
            ]
        )
    }

    @Test func continuousBasic() throws {
        var lexer = Lexer(source: Fixture.continuousBasic)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .continuous(
                    duration: 1,
                    intensity: .loud,
                    sharpness: .sharp,
                    adsr: nil
                ),
            ]
        )
    }

    @Test func continuousWithADSR() throws {
        var lexer = Lexer(source: Fixture.continuousWithADSR)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .continuous(
                    duration: 2,
                    intensity: .max,
                    sharpness: .balanced,
                    adsr: ADSR(attack: 0.05, decay: 0.15, sustain: 0.85, release: 1.0)
                ),
            ]
        )
    }

    @Test func rampFull() throws {
        var lexer = Lexer(source: Fixture.rampFull)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .ramp(
                    duration: 2,
                    intensity: Transition(from: .value(0.3), to: .value(1.0)),
                    sharpness: Transition(from: .value(0.2), to: .value(0.8)),
                    interval: Transition(from: 0.2, to: 0.05)
                ),
            ]
        )
    }

    @Test func rampWithAliases() throws {
        var lexer = Lexer(source: Fixture.rampWithAliases)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .ramp(
                    duration: 1,
                    intensity: Transition(from: .soft, to: .max),
                    sharpness: Transition(from: .dull, to: .sharp),
                    interval: nil
                ),
            ]
        )
    }

    @Test func rampPartial() throws {
        var lexer = Lexer(source: Fixture.rampPartial)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        #expect(
            nodes
            ==
            [
                .ramp(
                    duration: 1,
                    intensity: Transition(from: .silent, to: .loud),
                    sharpness: nil,
                    interval: nil
                ),
            ]
        )
    }
}
