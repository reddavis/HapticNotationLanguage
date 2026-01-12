# Haptic Notation Language

A human-readable text format for designing iOS Core Haptic patterns.

I love haptics. Though designing haptics in code feels like composing music by writing MIDI bytes. 

Haptic Notation Language is my attempt at sheet music, a human-readable notation for 
sketching haptic patterns quickly.

> [!WARNING]  
> Haptic Notation Language is not yet at v1.0.
> It's possible there will be breaking changes.

## Example

```swift
let notation = """
    loud sharp
    . 0.3s
    medium balanced
    . 0.3s
    soft dull
    """

let engine = try CHHapticEngine()
engine.playsHapticsOnly = true
try engine.start()

let pattern = try HapticNotationLanguage.parse(notation)
let player = try engine.makePlayer(with: pattern)
try player.start(atTime: CHHapticTimeImmediate)
```

This plays three taps: loud/sharp, medium, then soft/dull — each 0.3 seconds apart.

## Demo project

There's a demo project that you can fire up and play with.

---

## Installation

### Swift Package Manager

In Xcode:

1. Click `Project`.
2. Click `Package Dependencies`.
3. Click `+`.
4. Enter package URL: `https://github.com/reddavis/HapticNotationLanguage`.
5. Add `HapticNotationLanguage` to your app target.

---

## Core Concepts

### Intensity

How strong the haptic feels.

**Aliases**

| Alias | Value |
|-------|-------|
| `silent` | 0.0 |
| `soft` | 0.3 |
| `medium` | 0.5 |
| `loud` | 0.8 |
| `max` | 1.0 |

**Raw values**

Use `i` followed by a decimal: `i0.7`, `i0.25`, `i1.0`

### Sharpness

How the haptic feels — dull/rounded vs sharp.

**Aliases**

| Alias | Value |
|-------|-------|
| `dull` | 0.0 |
| `balanced` | 0.5 |
| `sharp` | 1.0 |

**Raw values**

Use `s` followed by a decimal: `s0.3`, `s0.8`, `s1.0`

### Combined Notation

Intensity and sharpness together, space-separated:

```
loud sharp      # aliases
soft dull
i0.7 s0.3       # raw values
loud s0.2       # mixed
i0.5 sharp
```

---

## Syntax Reference

### Comments

```
# This is a comment
loud sharp  # inline comment
```

### Rests

Use `.` to insert 0.1s silence between events.

This can also be followed by an optional time. 

```
loud sharp
. # Defaults to 0.1s 
soft dull
. 0.2s
medium balanced
```

---

## Transient events

A single haptic tap followed by a rest of 0.2s followed by another tap:

```
loud sharp
. 0.2s
medium dull
```

---

## Continuous events

A sustained haptic with optional envelope shaping:

```
continuous 1s:
  intensity: loud
  sharpness: sharp
```

With ADSR envelope:

```
continuous 2s:
  intensity: max
  sharpness: balanced
  adsr: 0.05, 0.15, 0.85, 1.0
```

#### ADSR Envelope

ADSR defines the intensity shape over time:

```
adsr: <attack>, <decay>, <sustain_level>, <release>
```

| Parameter | Description |
|-----------|-------------|
| `attack` | Progress point (0–1) where peak intensity is reached |
| `decay` | Progress point (0–1) where intensity drops to sustain level |
| `sustain_level` | Intensity level (0–1) to hold during sustain phase |
| `release` | Progress point (0–1) where fade-out ends |

The sustain phase runs from `decay` until `release` begins.

Example:

```
adsr: 0.1, 0.3, 0.8, 1.0
```

For a 2s continuous event:

| Phase | Time | Intensity |
|-------|------|-----------|
| Attack | 0 → 0.2s | 0 → 1.0 |
| Decay | 0.2s → 0.6s | 1.0 → 0.8 |
| Sustain | 0.6s → 2.0s | hold at 0.8 |
| Release | at 2.0s | ends |

If `adsr` is omitted, the intensity stays constant for the duration.

---

## Sequences

Play multiple events in order with consistent spacing:

```
sequence 0.15s:
  loud sharp
  medium balanced
  soft dull
```

Each event plays 0.15 seconds apart.

### Rests in Sequences

Use `.` for silence:

```
sequence 0.2s:
  max sharp
  .
  loud balanced
  .
  medium dull
```

Plays max sharp, skips a beat, loud balanced, skips a beat, medium dull.

---

## Loops

Repeat a pattern:

```
loop 3x 0.25s:
  soft sharp
```

Plays soft sharp three times, 0.25 seconds apart.

### Loop with Multiple Events

```
loop 2x 0.5s:
  loud sharp
  soft dull
```

Each iteration plays both events, repeating twice with 0.5s between iterations.

---

## Ramps

Gradually transition parameters over time:

```
ramp 2s:
  intensity: 0.3 > 1.0
  sharpness: 0.2 > 0.8
  interval: 0.2s > 0.05s
```

| Parameter | Description |
|-----------|-------------|
| `intensity` | Start > end intensity (0.0–1.0 or aliases) |
| `sharpness` | Start > end sharpness (0.0–1.0 or aliases) |
| `interval` | Start > end time between pulses |

### Using Aliases

```
ramp 1s:
  intensity: soft > max
  sharpness: dull > sharp
```

### Partial Ramps

Only specify what you need:

```
ramp 1s:
  intensity: silent > loud
```

If ommitted, the default values are:

| Parameter | Default value |
|-----------|-------------|
| `intensity` | 0.5 |
| `sharpness` | 0.5 |
| `interval` | 0.1 |

---

## Variables

Define reusable haptic patterns:

```
define tick:
  soft sharp

define thump:
  loud dull

thump
. 0.3s
tick
. 0.15s
tick
```

### Define a continuous

```
define buzz:
  continuous 0.5s:
    intensity: medium
    sharpness: dull
    adsr: 0.1, 0.2, 0.8, 1.0

buzz
```

### Define a sequence

```
define celebration:
  sequence 0.1s:
    medium balanced
    loud sharp
    max sharp

celebration
```

### Define a loop

```
define heartbeat:
  loop 2x 0.3s:
    loud balanced

heartbeat
```

---

## Complete Examples

### Double Tap Notification

```
define tick:
  soft sharp

tick
. 0.2s
tick
```

### Success Confirmation

```
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
```

### Warning Buzz

```
define warning:
  continuous 0.1s:
    intensity: max
    sharpness: sharp
    adsr: 0.05, 0.15, 0.85, 1.0

warning
. 0.2s
warning
. 0.2s
warning
```

### Accelerating Pulse

```
ramp 2s:
  intensity: 0.3 > 1.0
  sharpness: 0.2 > 0.8
  interval: 0.2s > 0.05s
```
