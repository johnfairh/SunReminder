//
//  Suggestion.swift
//  SunReminder
//
//  Created by John on 11/03/2026.
//

import Foundation
import SwiftSunriseSunset

private let gmtCalendar: Calendar = {
    var cal = Calendar(identifier: .gregorian)
    cal.timeZone = .gmt
    return cal
}()

private let ukTimeZone = TimeZone(identifier: "Europe/London")!

private extension TimerTime {
    var minutesSinceMidnight: Int {
        hour * 60 + minute.rawValue
    }

    /// These have to be in the same timezone...
    func difference(to other: TimerTime) -> Int {
        abs(minutesSinceMidnight - other.minutesSinceMidnight)
    }

    /// Set up a (GMT) timer time from an absolute timestamp.
    ///
    /// This rounds to the nearest representable time - worst case 7.5 minutes off one way or the other.
    init(_ date: Date) {
        let h = gmtCalendar.component(.hour, from: date)
        let m = gmtCalendar.component(.minute, from: date)

        // yikes what is this supposed to be!
        switch m {
        case 0...7: self.hour = h; self.minute = .oclock
        case 8...23: self.hour = h; self.minute = .fifteen
        case 24...37: self.hour = h; self.minute = .thirty
        case 38...52: self.hour = h; self.minute = .fortyfive
        default: self.hour = h + 1; self.minute = .oclock
        }
    }
}

private extension TimerState {
    var onTimeGMT: TimerTime {
        TimerTime(onTime.hour - gmtOffsetHours, onTime.minute)
    }

    var offTimeGMT: TimerTime {
        TimerTime(offTime.hour - gmtOffsetHours, offTime.minute)
    }

    init(gmtOffsetHours: Int, onTimeGMT: TimerTime, offTimeGMT: TimerTime) {
        self.gmtOffsetHours = gmtOffsetHours
        self.onTime = TimerTime(onTimeGMT.hour + gmtOffsetHours, onTimeGMT.minute)
        self.offTime = TimerTime(offTimeGMT.hour + gmtOffsetHours, offTimeGMT.minute)
    }
}

public enum Policy {
    public static func suggestNewTimerState(configuration: Configuration, current: TimerState = TimerState.initial, now: Date) throws -> TimerState? {
        guard let gmtSunrise = SwiftSunriseSunset.sunrise(for: now, in: .gmt,
                                                          latitude: configuration.latitude,
                                                          longitude: configuration.longitude) else {
            throw ReminderError("Backend calculation failed for sunrise")
        }

        guard let gmtSunset = SwiftSunriseSunset.sunset(for: now, in: .gmt,
                                                        latitude: configuration.latitude,
                                                        longitude: configuration.longitude) else {
            throw ReminderError("Backend calculation failed for sunset")
        }

        let gmtSunriseTimerTime = TimerTime(gmtSunrise)
        let gmtSunsetTimerTime = TimerTime(gmtSunset)
        let currentOnTimerTime = current.onTimeGMT
        let currentOffTimerTime = current.offTimeGMT

        guard currentOnTimerTime.difference(to: gmtSunsetTimerTime) >= configuration.eveningSlackMinutes ||
                currentOffTimerTime.difference(to: gmtSunriseTimerTime) >= configuration.morningSlackMinutes else {
            // current state is good enough
            return nil
        }

        let gmtOffsetHours = ukTimeZone.secondsFromGMT(for: now) / 3600

        let suggestion = TimerState(gmtOffsetHours: gmtOffsetHours,
                                    onTimeGMT: gmtSunsetTimerTime,
                                    offTimeGMT: gmtSunriseTimerTime)
        return suggestion
    }
}
