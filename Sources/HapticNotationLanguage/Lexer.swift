import Foundation

struct Lexer {
    private let source: String
    private var startIndex: String.Index
    private var currentIndex: String.Index
    private var indentStack: [Int] = [0]

    // Error tracking
    private var line: Int = 1
    private var column: Int = 1
    private var startLocation: SourceLocation = .init(line: 1, column: 1)

    private var currentLocation: SourceLocation {
        .init(line: line, column: column)
    }

    private var currentSpan: SourceSpan {
        .init(start: startLocation, end: currentLocation)
    }

    private var currentLexeme: String {
        String(source[startIndex..<currentIndex])
    }

    // MARK: Initialization

    init(source: String) {
        self.source = source
        self.startIndex = source.startIndex
        self.currentIndex = source.startIndex
    }

    // MARK: API

    mutating func scan() throws -> [Token] {
        var tokens: [Token] = []
        startIndex = source.startIndex
        currentIndex = source.startIndex

        while !isAtEnd {
            if tokens.last == .newline || tokens.isEmpty {
                startIndex = currentIndex
                startLocation = currentLocation

                let indentLength = consumeIndent()
                let currentIndent = indentStack.last!

                if peek == "\n" {
                    consume()
                    tokens.append(.newline)
                    continue
                }

                if peek == "#" {
                    if let token = try scanToken() {
                        tokens.append(token)
                    }
                    continue
                }

                if indentLength > currentIndent {
                    indentStack.append(indentLength)
                    tokens.append(.indent)
                } else {
                    while indentLength < indentStack.last! {
                        indentStack.removeLast()
                        tokens.append(.dedent)
                    }

                    guard indentLength == indentStack.last! else {
                        throw LexerError(
                            lexeme: currentLexeme,
                            span: currentSpan,
                            type: .inconsistentIndentation(
                                found: indentLength,
                                expected: indentStack.last!,
                            ),
                        )
                    }
                }
            }

            startIndex = currentIndex
            startLocation = currentLocation
            if let token = try scanToken() {
                tokens.append(token)
            }
        }

        // Close remaining indents
        while indentStack.count > 1 {
            indentStack.removeLast()
            tokens.append(.dedent)
        }

        return tokens
    }

    private mutating func scanToken() throws -> Token? {
        let character = consume()

        switch character {
        case ":":
            return .colon
        case ">":
            return .arrow
        case ",":
            return .comma
        case ".":
            if peek?.isWholeNumber != true {
                return .rest
            }
            // Decimal
            return try scanNumber(isPreviousCharacterDot: true)

        case "#":
            var comment = ""
            while !isAtEnd && peek != "\n" {
                comment.append(consume())
            }
            return .comment(comment)

        case " ", "\t", "\r":
            return nil

        case "\n":
            return .newline

        default:
            if character.isWholeNumber {
                return try scanNumber(isPreviousCharacterDot: false)
            } else if character.isLetter {
                return try scanIdentifier()
            } else {
                throw LexerError(
                    lexeme: currentLexeme,
                    span: currentSpan,
                    type: .unexpectedCharacter(character),
                )
            }
        }
    }

    private mutating func scanNumber(isPreviousCharacterDot: Bool) throws -> Token {
        while peek?.isWholeNumber == true {
            consume()
        }

        // Decimal part
        if !isPreviousCharacterDot && peek == "." && peekNext?.isWholeNumber == true {
            consume() // the "."
            while peek?.isWholeNumber == true {
                consume()
            }
        }

        guard let number = Double(String(source[startIndex..<currentIndex])) else {
            throw LexerError(
                lexeme: currentLexeme,
                span: currentSpan,
                type: .invalidNumber,
            )
        }

        // Check suffix
        switch peek {
        case "s":
            consume()
            return .time(number)
        case "x":
            consume()
            return .multiplier(Int(number))
        default:
            return .number(number)
        }
    }

    private mutating func scanIdentifier() throws -> Token {
        let firstChar = source[startIndex]

        if (firstChar == "i" || firstChar == "s") && peek?.isWholeNumber == true {
            while peek?.isWholeNumber == true {
                consume()
            }

            if peek == "." && peekNext?.isWholeNumber == true {
                consume()
                while peek?.isWholeNumber == true {
                    consume()
                }
            }

            let afterPrefix = source.index(after: startIndex)
            if let value = Float(String(source[afterPrefix..<currentIndex])) {
                return firstChar == "i" ? .intensityValue(value) : .sharpnessValue(value)
            }
        }

        while peek?.isLetter == true || peek?.isWholeNumber == true || peek == "_" {
            consume()
        }

        let lexeme = String(source[startIndex..<currentIndex])

        switch lexeme {
        // Keywords
        case "define":
            return .define
        case "sequence":
            return .sequence
        case "loop":
            return .loop
        case "ramp":
            return .ramp
        case "continuous":
            return .continuous

        // Properties
        case "intensity":
            return .intensity
        case "sharpness":
            return .sharpness
        case "interval":
            return .interval
        case "adsr":
            return .adsr
        case "curve":
            return .curve

        // Intensity aliases
        case "silent":
            return .silent
        case "soft":
            return .soft
        case "medium":
            return .medium
        case "loud":
            return .loud
        case "max":
            return .max

        // Sharpness aliases
        case "dull":
            return .dull
        case "balanced":
            return .balanced
        case "sharp":
            return .sharp

        // Curve aliases
        case "linear":
            return .linear
        case "easeIn":
            return .easeIn
        case "easeOut":
            return .easeOut
        case "easeInOut":
            return .easeInOut

        // Cubic
        case "cubic":
            return try scanCubicCurve()

        default:
            return .identifier(lexeme)
        }
    }

    private mutating func scanCubicCurve() throws -> Token {
        guard peek == "(" else {
            throw LexerError(
                lexeme: currentLexeme,
                span: currentSpan,
                type: .expectedCharacter("("),
            )
        }
        consume()

        var values: [Double] = []
        while values.count < 4 {
            consumeWhitespace()

            let numberStartIndex = currentIndex
            while peek?.isWholeNumber == true || peek == "." || peek == "-" {
                consume()
            }

            guard let value = Double(String(source[numberStartIndex..<currentIndex])) else {
                throw LexerError(
                    lexeme: currentLexeme,
                    span: currentSpan,
                    type: .invalidCubicValue,
                )
            }
            values.append(value)

            if values.count < 4 {
                guard peek == "," else {
                    throw LexerError(
                        lexeme: currentLexeme,
                        span: currentSpan,
                        type: .expectedCharacter(","),
                    )
                }
                consume()
            }
        }

        guard peek == ")" else {
            throw LexerError(
                lexeme: currentLexeme,
                span: currentSpan,
                type: .expectedCharacter(")"),
            )
        }
        consume()

        return .curveValue(values[0], values[1], values[2], values[3])
    }

    // MARK: Helpers

    private var isAtEnd: Bool {
        currentIndex >= source.endIndex
    }

    private var peek: Character? {
        guard !isAtEnd else { return nil }
        return source[currentIndex]
    }

    private var peekNext: Character? {
        let next = source.index(after: currentIndex)
        guard next < source.endIndex else { return nil }
        return source[next]
    }

    @discardableResult
    private mutating func consume() -> Character {
        let char = source[currentIndex]
        currentIndex = source.index(after: currentIndex)

        if char == "\n" {
            line += 1
            column = 1
        } else {
            column += 1
        }

        return char
    }

    private mutating func consumeIndent() -> Int {
        var count = 0
        while peek == " " {
            consume()
            count += 1
        }
        return count
    }

    private mutating func consumeWhitespace() {
        while peek == " " {
            consume()
        }
    }
}

struct LexerError: Error, Equatable {
    let lexeme: String
    let span: SourceSpan
    let type: ErrorType

    enum ErrorType: Equatable {
        case expectedCharacter(Character)
        case inconsistentIndentation(found: Int, expected: Int)
        case invalidCubicValue
        case invalidNumber
        case unexpectedCharacter(Character)
    }
}
