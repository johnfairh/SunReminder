import Testing
import Foundation
import SunReminder

@Test func basicSuggestion() async throws {
    let now = Date.now

    let s = try Policy.suggestNewTimerState(configuration: .stCrossMede, now: now)
    let suggestion = try #require(s)

    print("Today: \(suggestion)")
    var timerState = suggestion

    print("")

    // go a month forward, iterating the timer state....
    for i in 1...30 {
        let date = now.addingTimeInterval(60 * 60 * 24 * Double(i))

        if let suggestion = try Policy.suggestNewTimerState(configuration: .stCrossMede, current: timerState, now: date) {
            print("\(i)\(i < 10 ? " " : ""): \(suggestion)")
            timerState = suggestion
        } else {
            print("\(i)\(i < 10 ? " " : ""): (no)")
        }
    }
}
