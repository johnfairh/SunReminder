//
//  Model.swift
//  SunReminderApp
//

import Foundation

/// A timestamp that the mechanical timer can represent
struct TimerTime: Codable, Sendable, CustomStringConvertible {
    /// 24-hour, 0 to 23
    let hour: Int

    /// Let's try this and see how badly it goes...
    enum Minute: Int, Codable, Sendable, CustomStringConvertible {
        case oclock = 0
        case fifteen = 15
        case thirty = 30
        case fortyfive = 45

        var description: String {
            if self == .oclock { "00" } else { rawValue.description }
        }
    }
    let minute: Minute

    init(_ hour: Int, _ minute: Minute) {
        precondition(hour >= 0 && hour < 24, "Hour outside 0-23")
        self.hour = hour
        self.minute = minute
    }

    var text: String {
        let h12 = hour > 12 ? hour - 12 : hour
        return "\(h12):\(minute.description) \(hour >= 12 ? "PM" : "AM")"
    }

    var text24: String {
        "\(hour):\(minute.description)"
    }

    var description: String { text24 }
}

/// A precise clock time, to the minute (unlike TimerTime, not constrained to what the
/// mechanical timer can display).
struct ClockTime: CustomStringConvertible {
    /// 24-hour, 0 to 23
    let hour: Int
    /// 0 to 59
    let minute: Int

    init(_ hour: Int, _ minute: Int) {
        precondition(hour >= 0 && hour < 24, "Hour outside 0-23")
        precondition(minute >= 0 && minute < 60, "Minute outside 0-59")
        self.hour = hour
        self.minute = minute
    }

    var text: String {
        let h12 = hour > 12 ? hour - 12 : hour
        return "\(h12):\(String(format: "%02d", minute)) \(hour >= 12 ? "PM" : "AM")"
    }

    var description: String { text }
}

/// The state of the mechanical timer
struct TimerState: Codable, Sendable, CustomStringConvertible {
    /// When do the lights come on
    let onTime: TimerTime
    /// When do the lights go off
    let offTime: TimerTime
    /// What timezone is the timer in -- really we only expect 0 or +1 for BST
    let gmtOffsetHours: Int

    var description: String {
        "On: \(onTime), Off: \(offTime), GMT: \(gmtOffsetHours)"
    }

    static let initial = TimerState(
        onTime: .init(21, .oclock),
        offTime: .init(6, .oclock),
        gmtOffsetHours: 0
    )
}

/// The system configuration
struct Configuration: Codable, Sendable, CustomStringConvertible {
    /// Latitude of timer location
    let latitude: Double
    /// Longitude of timer location
    let longitude: Double

    /// Morning max slack time, minutes -- how long before or after sunrise the lights can turn off
    let morningSlackMinutes: Int
    /// Evening max slack time, minutes -- how long before or after sunset the lights can come on
    let eveningSlackMinutes: Int

    var description: String {
        "Lat:\(latitude), Long:\(longitude), AM slack:\(morningSlackMinutes)m, PM slack:\(eveningSlackMinutes)m"
    }

    static let initial = Configuration(
        latitude: 0,
        longitude: 0,
        morningSlackMinutes: 0,
        eveningSlackMinutes: 0,
    )

    static let stCrossMede = Configuration(
        latitude: 51.0598,
        longitude: -1.3101,
        morningSlackMinutes: 15,
        eveningSlackMinutes: 15
    )

    init(latitude: Double, longitude: Double, morningSlackMinutes: Int, eveningSlackMinutes: Int) {
        self.latitude = latitude
        self.longitude = longitude
        self.morningSlackMinutes = morningSlackMinutes
        self.eveningSlackMinutes = eveningSlackMinutes
    }
}

struct ReminderError: Error {
    let reason: String
    init(_ reason: String) {
        self.reason = reason
    }
}
