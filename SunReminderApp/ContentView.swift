import SwiftUI

struct ForecastRow: Identifiable {
    let date: Date
    let suggestion: TimerState?
    var id: Date { date }
}

struct ContentView: View {
    @State private var today: Date = .now
    @State private var sunrise: ClockTime?
    @State private var sunset: ClockTime?
    @State private var todaySuggestion: TimerState?
    @State private var forecast: [ForecastRow] = []
    @State private var errorMessage: String?

    private static let headerDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()

    private static let rowDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEE d MMM")
        return formatter
    }()

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text(Self.headerDateFormatter.string(from: today))
                    .font(.headline)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }

                if let sunrise, let sunset {
                    Label("Sunrise \(sunrise.text)", systemImage: "sunrise")
                    Label("Sunset \(sunset.text)", systemImage: "sunset")
                }

                GroupBox("Today") {
                    suggestionText(todaySuggestion)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding()

            List(forecast) { row in
                HStack {
                    Text(Self.rowDateFormatter.string(from: row.date))
                    Spacer()
                    suggestionText(row.suggestion)
                }
            }
        }
        .task {
            recompute()
            for await _ in NotificationCenter.default.notifications(named: .NSCalendarDayChanged) {
                today = .now
                recompute()
            }
        }
    }

    @ViewBuilder
    private func suggestionText(_ suggestion: TimerState?) -> some View {
        if let suggestion {
            Text("On \(suggestion.onTime.text), off \(suggestion.offTime.text)")
        } else {
            Text("No change needed")
                .foregroundStyle(.secondary)
        }
    }

    private func recompute() {
        do {
            let (sunriseTime, sunsetTime) = try Policy.sunriseSunset(configuration: .stCrossMede, now: today)
            sunrise = sunriseTime
            sunset = sunsetTime
            todaySuggestion = try Policy.suggestNewTimerState(configuration: .stCrossMede, now: today)

            var current = TimerState.initial
            var rows: [ForecastRow] = []
            for i in 1...20 {
                let date = Calendar.current.date(byAdding: .day, value: i, to: today)!
                if let suggestion = try Policy.suggestNewTimerState(configuration: .stCrossMede, current: current, now: date) {
                    current = suggestion
                    rows.append(ForecastRow(date: date, suggestion: suggestion))
                } else {
                    rows.append(ForecastRow(date: date, suggestion: nil))
                }
            }
            forecast = rows
            errorMessage = nil
        } catch {
            errorMessage = "\(error)"
        }
    }
}

#Preview {
    ContentView()
}
