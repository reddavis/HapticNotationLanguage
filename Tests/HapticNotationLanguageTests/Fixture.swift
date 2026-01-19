enum Fixture {
    static let comments = """
        # This is a comment
        loud sharp # Inline comment
        """

    static let transientWithAliases = """
        loud sharp
        . 0.2s
        soft dull
        . 0.2s
        medium balanced
        """

    static let transientWithRawValues = """
        i0.7 s0.3
        . 0.2s
        i1.0 s0.0
        """

    static let transientMixed = """
        loud s0.2
        . 0.2s
        i0.5 sharp
        """

    static let defineTransient = """
        define tick:
          soft sharp
        
        tick
        . 0.2s
        tick
        """

    static let defineContinuous = """
        define buzz:
          continuous 0.5s:
            intensity: medium
            sharpness: dull
            adsr: 0.1, 0.2, 0.8, 1.0
        
        buzz
        """

    static let defineSequence = """
        define celebration:
          sequence 0.1s:
            medium balanced
            loud sharp
            max sharp
        
        celebration
        """

    static let defineLoop = """
        define heartbeat:
          loop 2x 0.3s:
            loud balanced
        
        heartbeat
        """

    static let sequenceBasic = """
        sequence 0.15s:
          loud sharp
          medium balanced
          soft dull
        """

    static let sequenceWithRests = """
        sequence 0.2s:
          max sharp
          .
          loud balanced
          .
          medium dull
        """

    static let loopSimple = """
        loop 3x 0.25s:
          soft sharp
        """

    static let loopMultipleEvents = """
        loop 2x 0.5s:
          loud sharp
          soft dull
        """

    static let continuousBasic = """
        continuous 1s:
          intensity: loud
          sharpness: sharp
        """

    static let continuousWithADSR = """
        continuous 2s:
          intensity: max
          sharpness: balanced
          adsr: 0.05, 0.15, 0.85, 1.0
        """

    static let rampFull = """
        ramp 2s:
          intensity: 0.3 > 1.0
          sharpness: 0.2 > 0.8
          interval: 0.2s > 0.05s
          curve: cubic(0.42, 0, 0.58, 1)
        """

    static let rampWithAliases = """
        ramp 1s:
          intensity: soft > max
          sharpness: dull > sharp
          curve: easeInOut
        """

    static let rampPartial = """
        ramp 1s:
          intensity: silent > loud
        """

    static let complexPattern = """
        # Success notification with distinct phases
        
        define tick:
          soft sharp
        
        define thump:
          loud dull
        
        # Opening attention-grab
        thump
        
        # Brief pause, then confirmation double-tap
        . 0.3s
        tick
        . 0.15s
        tick
        
        # Satisfying completion buzz
        . 0.25s
        continuous 0.4s:
          intensity: medium
          sharpness: balanced
          adsr: 0.1, 0.3, 0.8, 1.0
        
        # Final flourish
        . 0.1s
        sequence 0.12s:
          soft dull
          medium balanced
          loud sharp
        """
}
