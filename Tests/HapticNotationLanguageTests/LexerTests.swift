import Testing
@testable import HapticNotationLanguage

struct LexerTests {
    @Test func comments() throws {
        var lexer = Lexer(source: Fixture.comments)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .comment(" This is a comment"),
                .newline,
                .loud,
                .sharp,
                .comment(" Inline comment"),
            ]
        )
    }

    @Test func transientWithAliases() throws {
        var lexer = Lexer(source: Fixture.transientWithAliases)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .loud,
                .sharp,
                .newline,
                .rest,
                .time(0.2),
                .newline,
                .soft,
                .dull,
                .newline,
                .rest,
                .time(0.2),
                .newline,
                .medium,
                .balanced,
            ]
        )
    }

    @Test func transientWithRawValues() throws {
        var lexer = Lexer(source: Fixture.transientWithRawValues)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .intensityValue(0.7),
                .sharpnessValue(0.3),
                .newline,
                .rest,
                .time(0.2),
                .newline,
                .intensityValue(1.0),
                .sharpnessValue(0.0),
            ]
        )
    }

    @Test func transientMixed() throws {
        var lexer = Lexer(source: Fixture.transientMixed)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .loud,
                .sharpnessValue(0.2),
                .newline,
                .rest,
                .time(0.2),
                .newline,
                .intensityValue(0.5),
                .sharp,
            ]
        )
    }

    @Test func defineTransient() throws {
        var lexer = Lexer(source: Fixture.defineTransient)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .define,
                .identifier("tick"),
                .colon,
                .newline,
                .indent,
                .soft,
                .sharp,
                .newline,
                .newline,
                .dedent,
                .identifier("tick"),
                .newline,
                .rest,
                .time(0.2),
                .newline,
                .identifier("tick"),
            ]
        )
    }

    @Test func defineContinuous() throws {
        var lexer = Lexer(source: Fixture.defineContinuous)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .define,
                .identifier("buzz"),
                .colon,
                .newline,
                .indent,
                .continuous,
                .time(0.5),
                .colon,
                .newline,
                .indent,
                .intensity,
                .colon,
                .medium,
                .newline,
                .sharpness,
                .colon,
                .dull,
                .newline,
                .adsr,
                .colon,
                .number(0.1),
                .comma,
                .number(0.2),
                .comma,
                .number(0.8),
                .comma,
                .number(1.0),
                .newline,
                .newline,
                .dedent,
                .dedent,
                .identifier("buzz"),
            ]
        )
    }

    @Test func defineSequence() throws {
        var lexer = Lexer(source: Fixture.defineSequence)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .define,
                .identifier("celebration"),
                .colon,
                .newline,
                .indent,
                .sequence,
                .time(0.1),
                .colon,
                .newline,
                .indent,
                .medium,
                .balanced,
                .newline,
                .loud,
                .sharp,
                .newline,
                .max,
                .sharp,
                .newline,
                .newline,
                .dedent,
                .dedent,
                .identifier("celebration"),
            ]
        )
    }

    @Test func defineLoop() throws {
        var lexer = Lexer(source: Fixture.defineLoop)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .define,
                .identifier("heartbeat"),
                .colon,
                .newline,
                .indent,
                .loop,
                .multiplier(2),
                .time(0.3),
                .colon,
                .newline,
                .indent,
                .loud,
                .balanced,
                .newline,
                .newline,
                .dedent,
                .dedent,
                .identifier("heartbeat"),
            ]
        )
    }

    @Test func sequenceBasic() throws {
        var lexer = Lexer(source: Fixture.sequenceBasic)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .sequence,
                .time(0.15),
                .colon,
                .newline,
                .indent,
                .loud,
                .sharp,
                .newline,
                .medium,
                .balanced,
                .newline,
                .soft,
                .dull,
                .dedent,
            ]
        )
    }

    @Test func sequenceWithRests() throws {
        var lexer = Lexer(source: Fixture.sequenceWithRests)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .sequence,
                .time(0.2),
                .colon,
                .newline,
                .indent,
                .max,
                .sharp,
                .newline,
                .rest,
                .newline,
                .loud,
                .balanced,
                .newline,
                .rest,
                .newline,
                .medium,
                .dull,
                .dedent,
            ]
        )
    }

    @Test func loopSimple() throws {
        var lexer = Lexer(source: Fixture.loopSimple)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .loop,
                .multiplier(3),
                .time(0.25),
                .colon,
                .newline,
                .indent,
                .soft,
                .sharp,
                .dedent,
            ]
        )
    }

    @Test func loopMultipleEvents() throws {
        var lexer = Lexer(source: Fixture.loopMultipleEvents)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .loop,
                .multiplier(2),
                .time(0.5),
                .colon,
                .newline,
                .indent,
                .loud,
                .sharp,
                .newline,
                .soft,
                .dull,
                .dedent,
            ]
        )
    }

    @Test func continuousBasic() throws {
        var lexer = Lexer(source: Fixture.continuousBasic)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .continuous,
                .time(1),
                .colon,
                .newline,
                .indent,
                .intensity,
                .colon,
                .loud,
                .newline,
                .sharpness,
                .colon,
                .sharp,
                .dedent,
            ]
        )
    }

    @Test func continuousWithADSR() throws {
        var lexer = Lexer(source: Fixture.continuousWithADSR)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .continuous,
                .time(2),
                .colon,
                .newline,
                .indent,
                .intensity,
                .colon,
                .max,
                .newline,
                .sharpness,
                .colon,
                .balanced,
                .newline,
                .adsr,
                .colon,
                .number(0.05),
                .comma,
                .number(0.15),
                .comma,
                .number(0.85),
                .comma,
                .number(1.0),
                .dedent,
            ]
        )
    }

    @Test func rampFull() throws {
        var lexer = Lexer(source: Fixture.rampFull)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .ramp,
                .time(2),
                .colon,
                .newline,
                .indent,
                .intensity,
                .colon,
                .number(0.3),
                .arrow,
                .number(1.0),
                .newline,
                .sharpness,
                .colon,
                .number(0.2),
                .arrow,
                .number(0.8),
                .newline,
                .interval,
                .colon,
                .time(0.2),
                .arrow,
                .time(0.05),
                .dedent,
            ]
        )
    }

    @Test func rampWithAliases() throws {
        var lexer = Lexer(source: Fixture.rampWithAliases)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .ramp,
                .time(1),
                .colon,
                .newline,
                .indent,
                .intensity,
                .colon,
                .soft,
                .arrow,
                .max,
                .newline,
                .sharpness,
                .colon,
                .dull,
                .arrow,
                .sharp,
                .dedent,
            ]
        )
    }

    @Test func rampPartial() throws {
        var lexer = Lexer(source: Fixture.rampPartial)
        let tokens = try lexer.scan()

        #expect(
            tokens
            ==
            [
                .ramp,
                .time(1),
                .colon,
                .newline,
                .indent,
                .intensity,
                .colon,
                .silent,
                .arrow,
                .loud,
                .dedent,
            ]
        )
    }

    // MARK Error handling

    @Test func inconsistentIndentation() throws {
        let source = """
            sequence 0.15s:
                  loud sharp
               medium balanced
            """

        var lexer = Lexer(source: source)
        #expect(throws: LexerError(
            lexeme: "   ",
            span: SourceSpan(
                start: SourceLocation(line: 3, column: 1),
                end: SourceLocation(line: 3, column: 4)
            ),
            type: .inconsistentIndentation(found: 3, expected: 0),
        )) {
            _ = try lexer.scan()
        }
    }

    @Test func unexpectedCharacter() throws {
        let source = "loud @sharp"

        var lexer = Lexer(source: source)
        #expect(throws: LexerError(
            lexeme: "@",
            span: SourceSpan(
                start: SourceLocation(line: 1, column: 6),
                end: SourceLocation(line: 1, column: 7)
            ),
            type: .unexpectedCharacter("@"),
        )) {
            _ = try lexer.scan()
        }
    }

    @Test func unexpectedCharacterOnSecondLine() throws {
        let source = """
            loud sharp
            soft % dull
            """

        var lexer = Lexer(source: source)
        #expect(throws: LexerError(
            lexeme: "%",
            span: SourceSpan(
                start: SourceLocation(line: 2, column: 6),
                end: SourceLocation(line: 2, column: 7)
            ),
            type: .unexpectedCharacter("%"),
        )) {
            _ = try lexer.scan()
        }
    }
}
