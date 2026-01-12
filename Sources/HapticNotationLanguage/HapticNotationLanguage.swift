import CoreHaptics

public struct HapticNotationLanguage {
    public static func parse(_ notation: String) throws -> CHHapticPattern {
        var lexer = Lexer(source: notation)
        let tokens = try lexer.scan()
        var parser = Parser(tokens: tokens)
        let nodes = try parser.parse()

        let interpreter = Interpreter(nodes: nodes
        let pattern = try interpreter.interpret()
        return try CHHapticPattern(pattern)
    }
}
