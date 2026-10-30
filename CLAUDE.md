# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```sh
swift build                                  # build
swift test                                   # run all tests (Swift Testing, not XCTest)
swift test --filter basicSuggestion          # run a single test by name
```

Requires Swift tools 6.4, Swift 6 language mode, and macOS 26+.

## Purpose

SunReminder is a library that tells you when to reset a **mechanical light timer** so that the lights come on near sunset and go off near sunrise. Sunrise and sunset times come from the `SwiftSunriseSunset` package (`johnfairh/swift-sunrise-sunset`).

The software is designed only for the UK in the 21st century.  It is not the
software's job to police this.

## Architecture

- `Sources/SunReminder/Model.swift` holds the public value types:
  - `TimerTime`: a time the physical timer can show. The hour is 0–23 and the minute must be one of `Minute`'s cases: 00, 15, 30 or 45.
  - `TimerState`: the on and off times as shown on the timer, plus `gmtOffsetHours`, which is 0 for GMT and 1 for BST.
  - `Configuration`: the location (lat/long) plus morning and evening slack in minutes. `stCrossMede` is the real deployment preset.
- `Sources/SunReminder/Policy.swift` holds `Policy.suggestNewTimerState(configuration:current:now:)`. It returns a new `TimerState`, or `nil` when the current settings are within slack of both sunrise and sunset.

### Time zone handling

`TimerState` stores *local* timer times. All policy calculations happen in **GMT**:

1. Private extensions in `Policy.swift` convert the current state to GMT (`onTimeGMT` and `offTimeGMT`).
2. Sunrise and sunset are computed in `.gmt` and rounded to the nearest quarter hour (`TimerTime.init(Date)`).
3. The new state is converted back to local time with the `Europe/London` offset for `now`. This time zone is hard-coded.

Keep this convention when changing the policy: compare times only within a single time zone. `difference(to:)` assumes this.

## Tests

`Tests/SunReminderTests` uses Swift Testing (`@Test`, `#require`). The current test is exploratory. It starts from `Date.now`, simulates 30 days, and prints the suggestions without checking any values.
