//
//  CalendarReminder.swift
//  SunReminderApp
//

import EventKit

enum CalendarReminder {
    /// Add a non-repeating "Check SunReminder" event at 08:25 local time on `date`,
    /// alerting at the event time.
    static func add(on date: Date) async throws {
        let store = EKEventStore()
        guard try await store.requestWriteOnlyAccessToEvents() else {
            throw ReminderError("Calendar access not granted")
        }
        guard let start = Calendar.current.date(bySettingHour: 8, minute: 25, second: 0, of: date) else {
            throw ReminderError("Couldn't calculate reminder time")
        }
        guard let calendar = store.defaultCalendarForNewEvents else {
            throw ReminderError("No default calendar for new events")
        }

        let event = EKEvent(eventStore: store)
        event.title = "Check SunReminder"
        event.startDate = start
        event.endDate = start.addingTimeInterval(15 * 60)
        event.calendar = calendar
        event.addAlarm(EKAlarm(relativeOffset: 0))
        try store.save(event, span: .thisEvent)
    }
}
