# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

SunReminderApp is a single-screen iPhone app that tells the user when to reset a
**mechanical light timer** so the lights come on near sunset and go off near sunrise.
It's built for one specific deployment: `Configuration.stCrossMede` ("St Cross Mede"),
hardcoded as the location. The screen shows: today's date, today's sunrise/sunset (to
the minute), whether the timer needs resetting today, and a 20-day schedule of future
suggested on/off times.

Designed only for the UK in the 21st century; not the software's job to police this.

## Project structure

`project.yml` / `SunReminderApp/` is the whole repo — a single iOS app target
(iOS 27+ deployment target). It uses Xcode's file-system-synchronized group, so any
`.swift` file dropped into `SunReminderApp/` is picked up automatically — no explicit
project-file registration needed.

- `Model.swift` — `TimerTime` (quarter-hour granularity, what the mechanical timer can
  show), `ClockTime` (arbitrary-minute granularity, for display-only values like the
  sunrise/sunset labels), `TimerState`, `Configuration`, `ReminderError`.
- `Policy.swift` — `Policy.sunriseSunset(configuration:now:)` (exact sunrise/sunset to
  the minute) and `Policy.suggestNewTimerState(configuration:current:now:)` (returns a
  new `TimerState`, or `nil` if current settings are within slack of both sunrise and
  sunset).
- `ContentView.swift` — the single screen: date header, sunrise/sunset + today's
  suggestion as `Label`s, a scrollable list of the next 20 days. Forces
  `.preferredColorScheme(.dark)` with a custom dark-navy `backgroundColor`, relying on
  `.primary`/`.secondary` to auto-adapt to white/light-gray rather than hardcoding
  foreground colors. Recomputes on launch and at midnight (`.NSCalendarDayChanged`).

Depends directly on the `SwiftSunriseSunset` package
(`johnfairh/swift-sunrise-sunset`) as a package dependency on the app target.

## Time zone handling

Timer times are stored *local*; policy calculations happen in **GMT**:

1. Private extensions convert the current state to GMT (`onTimeGMT`/`offTimeGMT`).
2. Sunrise/sunset are computed in `.gmt`. `suggestNewTimerState` rounds to the nearest
   quarter hour (`TimerTime.init(Date)`); `sunriseSunset` does not round (`ClockTime`).
3. Results convert back to local time using the `Europe/London` GMT offset for `now`
   (hardcoded time zone).

Compare times only within a single time zone — `TimerTime.difference(to:)` assumes this.

## Project file

`project.yml` is an xcodegen file.  Do not change `SunReminder.xcodeproj` directly,
instead modify `project.yml` and regenerate `SunReminder.xcodeproj` using `xcodegen generate`.

## Commands

`xcodegen generate` to update the Xcode project file `SunReminder.xcodeproj`.

Build/run/test via Xcode (or `xcodebuild`) targeting the `SunReminder` scheme/app
target in `SunReminder.xcodeproj`.
