import Foundation

struct Parser {
    private var tokens: [Token]
    private var current: Int = 0

    // MARK: Initialization

    init(tokens: [Token]) {
        self.tokens = tokens
    }

    // MARK: API

    mutating func parse() throws(ParserError) -> [Node] {
        var nodes: [Node] = []
        while !isAtEnd {
            skipNewlinesAndComments()
            if isAtEnd { break }

            guard let node = try parseStatement() else {
                continue
            }
            nodes.append(node)
        }

        return nodes
    }

    // MARK: Statement

    private mutating  func parseStatement() throws(ParserError) -> Node? {
        switch peek {
        case .continuous:
            return try parseContinuous()
        case .define:
            return try parseDefine()
        case .loop:
            return try parseLoop()
        case .ramp:
            return try parseRamp()
        case .identifier:
            return try parseIdentifier()
        case .rest:
            return try parseRest()
        case .sequence:
            return try parseSequence()
        case .silent, .soft, .medium, .loud, .max, .intensityValue:
            return try parseTransient()
        default:
            advance()
        }

        return nil
    }

    // MARK: Continuous

    private mutating func parseContinuous() throws(ParserError) -> Node {
        try consume(.continuous)

        let duration = try parseTime()

        try consume(.colon)
        try consume(.newline)
        try consume(.indent)

        var intensity: Intensity = .medium
        var sharpness: Sharpness = .balanced
        var adsr: ADSR? = nil

        while peek != .dedent && !isAtEnd {
            skipNewlinesAndComments()
            if peek == .dedent { break }

            switch peek {
            case .intensity:
                advance()
                try consume(.colon)
                intensity = try parseIntensity()

            case .sharpness:
                advance()
                try consume(.colon)
                sharpness = try parseSharpness()

            case .adsr:
                try consume(.adsr)
                try consume(.colon)
                adsr = try parseADSR()

            default:
                throw ParserError.unexpectedToken(peek)
            }

            skipNewlinesAndComments()
        }

        try consume(.dedent)

        return .continuous(
            duration: duration,
            intensity: intensity,
            sharpness: sharpness,
            adsr: adsr,
        )
    }

    // MARK: Define

    private mutating func parseDefine() throws(ParserError) -> Node {
        try consume(.define)

        guard case .identifier(let identifier) = peek else {
            throw .expectedIdentifier
        }
        advance()

        try consume(.colon)
        try consume(.newline)
        try consume(.indent)

        let node: Node
        switch peek {
        case .continuous:
            node = try parseContinuous()
        case .sequence:
            node = try parseSequence()
        case .loop:
            node = try parseLoop()
        default:
            let (intensity, sharpness) = try parseIntensityAndSharpness()
            node = .transient(
                intensity: intensity,
                sharpness: sharpness,
            )
            skipNewlinesAndComments()
        }

        try consume(.dedent)
        return .define(name: identifier, body: node)
    }

    private mutating func parseIdentifier() throws(ParserError) -> Node {
        guard case .identifier(let identifier) = peek else {
            throw .expectedIdentifier
        }
        advance()
        return .reference(identifier)
    }

    // MARK: Loop

    private mutating func parseLoop() throws(ParserError) -> Node {
        try consume(.loop)

        guard case .multiplier(let multiplier) = peek else {
            throw .expectedMultiplier
        }
        advance()

        let interval = try parseTime()

        try consume(.colon)
        try consume(.newline)
        try consume(.indent)

        var nodes: [Node] = []
        while peek != .dedent && !isAtEnd {
            skipNewlinesAndComments()
            guard peek != .dedent else { break }

            if peek == .rest {
                advance()
                var duration: TimeInterval?
                if case .time(let timeInterval) = peek {
                    duration = timeInterval
                    advance()
                }
                nodes.append(.rest(duration))
            } else if case .identifier(let name) = peek {
                advance()
                nodes.append(.reference(name))
            } else {
                let (intensity, sharpness) = try parseIntensityAndSharpness()
                nodes.append(
                    .transient(
                        intensity: intensity,
                        sharpness: sharpness,
                    )
                )
            }
        }

        try consume(.dedent)
        return .loop(
            count: multiplier,
            interval: interval,
            body: nodes,
        )
    }

    // MARK: Ramp

    private mutating func parseRamp() throws(ParserError) -> Node {
        try consume(.ramp)
        let duration = try parseTime()

        try consume(.colon)
        try consume(.newline)
        try consume(.indent)

        var intensity: Transition<Intensity>?
        var sharpness: Transition<Sharpness>?
        var interval: Transition<TimeInterval>?

        while peek != .dedent && !isAtEnd {
            skipNewlinesAndComments()
            if peek == .dedent { break }

            switch peek {
            case .intensity:
                advance()
                try consume(.colon)
                let start = try parseIntensity()
                try consume(.arrow)
                let end = try parseIntensity()
                intensity = Transition(from: start, to: end)

            case .sharpness:
                advance()
                try consume(.colon)
                let start = try parseSharpness()
                try consume(.arrow)
                let end = try parseSharpness()
                sharpness = Transition(from: start, to: end)

            case .interval:
                advance()
                try consume(.colon)
                let start = try parseTime()
                try consume(.arrow)
                let end = try parseTime()
                interval = Transition(from: start, to: end)

            default:
                throw ParserError.unexpectedToken(peek)
            }

            skipNewlinesAndComments()
        }

        try consume(.dedent)
        return .ramp(
            duration: duration,
            intensity: intensity,
            sharpness: sharpness,
            interval: interval,
        )
    }

    // MARK: Sequence

    private mutating func parseSequence() throws(ParserError) -> Node {
        try consume(.sequence)
        let interval = try parseTime()

        try consume(.colon)
        try consume(.newline)
        try consume(.indent)

        var nodes: [Node] = []
        while peek != .dedent && !isAtEnd {
            skipNewlinesAndComments()
            guard peek != .dedent else { break }

            if peek == .rest {
                advance()
                var duration: TimeInterval?
                if case .time(let timeInterval) = peek {
                    duration = timeInterval
                    advance()
                }
                nodes.append(.rest(duration))
            } else if case .identifier(let name) = peek {
                advance()
                nodes.append(.reference(name))
            } else {
                let (intensity, sharpness) = try parseIntensityAndSharpness()
                nodes.append(
                    .transient(
                        intensity: intensity,
                        sharpness: sharpness,
                    )
                )
            }
        }

        try consume(.dedent)
        return .sequence(interval: interval, body: nodes)
    }

    // MARK: Rest

    private mutating func parseRest() throws(ParserError) -> Node {
        try consume(.rest)
        var duration: TimeInterval? = nil
        if case .time(let time) = peek {
            duration = time
            advance()
        }
        return .rest(duration)
    }

    // MARK: Transient

    private mutating func parseTransient() throws(ParserError) -> Node {
        let (intensity, sharpness) = try parseIntensityAndSharpness()
        skipNewlinesAndComments()

        return .transient(
            intensity: intensity,
            sharpness: sharpness,
        )
    }

    // MARK: Single value

    private mutating func parseIntensityAndSharpness()
    throws(ParserError) -> (Intensity, Sharpness) {
        let intensity = try parseIntensity()
        let sharpness = try parseSharpness()
        return (intensity, sharpness)
    }

    private mutating func parseIntensity() throws(ParserError) -> Intensity {
        switch peek {
        case .silent:
            advance()
            return .silent
        case .soft:
            advance()
            return .soft
        case .medium:
            advance()
            return .medium
        case .loud:
            advance()
            return .loud
        case .max:
            advance()
            return .max
        case .intensityValue(let value):
            advance()
            return .value(value)
        case .number(let value):
            advance()
            return .value(Float(value))
        default:
            throw .expectedIntensity
        }
    }

    private mutating func parseSharpness() throws(ParserError) -> Sharpness {
        switch peek {
        case .dull:
            advance()
            return .dull
        case .balanced:
            advance()
            return .balanced
        case .sharp:
            advance()
            return .sharp
        case .sharpnessValue(let value):
            advance()
            return .value(value)
        case .number(let value):
            advance()
            return .value(Float(value))
        default:
            throw .expectedSharpness
        }
    }

    private mutating func parseADSR() throws(ParserError) -> ADSR {
        let attack = try parseNumber()
        try consume(.comma)
        let decay = try parseNumber()
        try consume(.comma)
        let sustain = try parseNumber()
        try consume(.comma)
        let release = try parseNumber()

        return ADSR(
            attack: attack,
            decay: decay,
            sustain: sustain,
            release: release
        )
    }

    private mutating func parseNumber() throws(ParserError) -> Double {
        guard case .number(let value) = peek else {
            throw .expectedNumber
        }
        advance()
        return value
    }

    private mutating func parseTime() throws(ParserError) -> TimeInterval {
        guard case .time(let timeInterval) = peek else {
            throw .expectedTime
        }
        advance()
        return timeInterval
    }

    // MARK: Helpers

    private var isAtEnd: Bool {
        current >= tokens.count
    }

    private var peek: Token {
        guard !isAtEnd else { return .dedent }
        return tokens[current]
    }

    @discardableResult
    private mutating func advance() -> Token {
        let token = peek
        current += 1
        return token
    }

    private mutating func consume(_ expected: Token) throws(ParserError) {
        if peek == expected {
            advance()
        } else {
            throw ParserError.expected(expected, got: peek)
        }
    }

    private mutating func skipNewlinesAndComments() {
        while !isAtEnd {
            switch peek {
            case .newline, .comment:
                advance()
            default:
                return
            }
        }
    }
}

enum ParserError: Error {
    case unexpectedToken(Token)
    case expectedIdentifier
    case expectedTime
    case expectedMultiplier
    case expectedIntensity
    case expectedSharpness
    case expectedNumber
    case expected(Token, got: Token)
}
