struct HNLExample: Equatable, Identifiable {
    let id: Int
    let title: String
    let notation: String
}

extension HNLExample {
    static let simpleTaps = HNLExample(
        id: 1,
        title: "Simple Taps",
        notation: """
            loud sharp
            . 0.2s
            soft dull
            . 0.2s
            medium balanced
            """
    )

    static let rawValues = HNLExample(
        id: 2,
        title: "Raw Values",
        notation: """
            i0.7 s0.3
            . 0.2s
            i1.0 s0.0
            """
    )

    static let reusableTap = HNLExample(
        id: 3,
        title: "Reusable Tap",
        notation: """
            define tick:
              medium sharp
            
            tick
            . 0.2s
            tick
            """
    )

    static let buzzWithEnvelope = HNLExample(
        id: 4,
        title: "Buzz with Envelope",
        notation: """
            define buzz:
              continuous 0.5s:
                intensity: medium
                sharpness: dull
                adsr: 0.1, 0.2, 0.8, 1.0
            
            buzz
            """
    )

    static let celebrationSequence = HNLExample(
        id: 5,
        title: "Celebration Sequence",
        notation: """
            define celebration:
              sequence 0.1s:
                medium balanced
                loud sharp
                max sharp
            
            celebration
            """
    )

    static let heartbeat = HNLExample(
        id: 6,
        title: "Heartbeat",
        notation: """
            define heartbeat:
              loop 2x 0.3s:
                loud balanced
            
            heartbeat
            """
    )

    static let basicSequence = HNLExample(
        id: 7,
        title: "Basic Sequence",
        notation: """
            sequence 0.15s:
              loud sharp
              medium balanced
              soft dull
            """
    )

    static let sequenceWithRests = HNLExample(
        id: 8,
        title: "Sequence with Rests",
        notation: """
            sequence 0.2s:
              max sharp
              .
              loud balanced
              .
              medium dull
            """
    )

    static let simpleLoop = HNLExample(
        id: 9,
        title: "Simple Loop",
        notation: """
            loop 3x 0.25s:
              medium sharp
            """
    )

    static let loopWithMultipleEvents = HNLExample(
        id: 10,
        title: "Loop with Multiple Events",
        notation: """
            loop 2x 0.5s:
              loud sharp
              soft dull
            """
    )

    static let continuousBuzz = HNLExample(
        id: 11,
        title: "Continuous Buzz",
        notation: """
            continuous 1s:
              intensity: loud
              sharpness: sharp
            """
    )

    static let continuousWithADSR = HNLExample(
        id: 12,
        title: "Continuous with ADSR",
        notation: """
            continuous 2s:
              intensity: max
              sharpness: balanced
              adsr: 0.05, 0.15, 0.85, 1.0
            """
    )

    static let acceleratingRamp = HNLExample(
        id: 13,
        title: "Accelerating Ramp",
        notation: """
            ramp 2s:
              intensity: 0.3 > 1.0
              sharpness: 0.2 > 0.8
              interval: 0.2s > 0.05s
            """
    )

    static let rampWithAliases = HNLExample(
        id: 14,
        title: "Ramp with Aliases",
        notation: """
            ramp 1s:
              intensity: soft > max
              sharpness: dull > sharp
            """
    )

    static let complexNotification = HNLExample(
        id: 15,
        title: "Complex Notification",
        notation: """
            define tick:
              medium sharp
            
            define thump:
              loud dull
            
            thump
            
            . 0.3s
            tick
            . 0.15s
            tick
            
            . 0.4s
            continuous 0.4s:
              intensity: medium
              sharpness: balanced
              adsr: 0.1, 0.3, 0.8, 0.9
            
            . 0.3s
            sequence 0.5s:
              loud dull
              loud dull
              loud dull
            """
    )

    static let all: [HNLExample] = [
        .simpleTaps,
        .rawValues,
        .reusableTap,
        .buzzWithEnvelope,
        .celebrationSequence,
        .heartbeat,
        .basicSequence,
        .sequenceWithRests,
        .simpleLoop,
        .loopWithMultipleEvents,
        .continuousBuzz,
        .continuousWithADSR,
        .acceleratingRamp,
        .rampWithAliases,
        .complexNotification,
    ]
}
