import Foundation

enum Token: Equatable {
    // Keywords
    case define
    case sequence
    case loop
    case ramp
    case continuous

    // Properties
    case intensity
    case sharpness
    case interval
    case adsr
    case curve

    // Intensity aliases
    case silent
    case soft
    case medium
    case loud
    case max

    // Sharpness aliases
    case dull
    case balanced
    case sharp

    // Timing curve aliases
    case linear
    case easeInOut
    case easeIn
    case easeOut

    // Literals
    case curveValue(Double, Double, Double, Double)
    case intensityValue(Float)
    case sharpnessValue(Float)
    case number(Double)
    case time(TimeInterval)
    case multiplier(Int)

    // Symbols
    case colon
    case arrow
    case comma
    case rest

    // Structure
    case newline
    case indent
    case dedent

    // Other
    case identifier(String)
    case comment(String)
}
