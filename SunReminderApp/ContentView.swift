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

    private static let backgroundColor = Color(red: 0.04, green: 0.09, blue: 0.22)

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .center, spacing: 12) {
                Text(Self.headerDateFormatter.string(from: today))
                    .font(.title)
                    .fontWeight(.semibold)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }

                VStack(alignment: .center) {
                    if let sunrise, let sunset {
                        Label("Sunrise \(sunrise.text)", systemImage: "sunrise")
                        Label("Sunset \(sunset.text)", systemImage: "sunset")
                    }

                    if let todaySuggestion {
                        Label("On \(todaySuggestion.onTime.text), off \(todaySuggestion.offTime.text)", systemImage: "clock")
                            .padding([.top])
                    } else {
                        Label("No change needed", systemImage: "clock")
                            .foregroundStyle(.secondary)
                    }
                }
                .font(.title3)
                .fontWeight(.medium)
            }
            .padding()

            List(forecast) { row in
                HStack {
                    Text(Self.rowDateFormatter.string(from: row.date))
                    Spacer()
                    suggestionText(row.suggestion)
                }
                .font(.subheadline)
                .listRowInsets(.vertical, 6)
                .listRowBackground(Self.backgroundColor)
            }
            .environment(\.defaultMinListRowHeight, 30)
            .scrollContentBackground(.hidden)
        }
        .background(Self.backgroundColor.ignoresSafeArea())
        .preferredColorScheme(.dark)
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
            (sunrise, sunset) = try Policy.sunriseSunset(configuration: .stCrossMede, now: today)
            todaySuggestion = try Policy.suggestNewTimerState(configuration: .stCrossMede, now: today)

            var current = TimerState.initial
            var rows: [ForecastRow] = []
            for i in 1...19 {
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
