//
//  Model.swift
//  SunReminder
//
//  Created by John on 11/03/2026.
//

import Foundation

/// A timestamp that the mechanical timer can represent
public struct TimerTime: Codable, Sendable, CustomStringConvertible {
    /// 24-hour, 0 to 23
    public let hour: Int

    /// Let's try this and see how badly it goes...
    public enum Minute: Int, Codable, Sendable, CustomStringConvertible {
        case oclock = 0
        case fifteen = 15
        case thirty = 30
        case fortyfive = 45

        public var description: String {
            if self == .oclock { "00" } else { rawValue.description }
        }
    }
    public let minute: Minute

    public init(_ hour: Int, _ minute: Minute) {
        precondition(hour >= 0 && hour < 24, "Hour outside 0-23")
        self.hour = hour
        self.minute = minute
    }

    public var text: String {
        let h12 = hour > 12 ? hour - 12 : hour
        return "\(h12):\(minute.description) \(hour >= 12 ? "PM" : "AM")"
    }

    public var text24: String {
        "\(hour):\(minute.description)"
    }

    public var description: String { text24 }
}

/// The state of the mechanical timer
public struct TimerState: Codable, Sendable, CustomStringConvertible {
    /// When do the lights come on
    public let onTime: TimerTime
    /// When do the lights go off
    public let offTime: TimerTime
    /// What timezone is the timer in -- really we only expect 0 or +1 for BST
    public let gmtOffsetHours: Int

    public var description: String {
        "On: \(onTime), Off: \(offTime), GMT: \(gmtOffsetHours)"
    }

    public static let initial = TimerState(
        onTime: .init(21, .oclock),
        offTime: .init(6, .oclock),
        gmtOffsetHours: 0
    )
}

/// The system configuration
public struct Configuration: Codable, Sendable, CustomStringConvertible {
    /// Latitude of timer location
    public let latitude: Double
    /// Longitude of timer location
    public let longitude: Double

    /// Morning max slack time, minutes -- how long before or after sunrise the lights can turn off
    public let morningSlackMinutes: Int
    /// Evening max slack time, minutes -- how long before or after sunset the lights can come on
    public let eveningSlackMinutes: Int

    public var description: String {
        "Lat:\(latitude), Long:\(longitude), AM slack:\(morningSlackMinutes)m, PM slack:\(eveningSlackMinutes)m"
    }

    public static let initial = Configuration(
        latitude: 0,
        longitude: 0,
        morningSlackMinutes: 0,
        eveningSlackMinutes: 0,
    )

    public static let stCrossMede = Configuration(
        latitude: 51.0598,
        longitude: -1.3101,
        morningSlackMinutes: 15,
        eveningSlackMinutes: 15
    )

    public init(latitude: Double, longitude: Double, morningSlackMinutes: Int, eveningSlackMinutes: Int) {
        self.latitude = latitude
        self.longitude = longitude
        self.morningSlackMinutes = morningSlackMinutes
        self.eveningSlackMinutes = eveningSlackMinutes
    }
}

public struct ReminderError: Error {
    public let reason: String
    init(_ reason: String) {
        self.reason = reason
    }
}
