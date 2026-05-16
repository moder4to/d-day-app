import SwiftUI
import WidgetKit

struct DDayWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: DaySurfaceSnapshot
}

struct DDayTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> DDayWidgetEntry {
        DDayWidgetEntry(date: .now, snapshot: .placeholder)
    }

    func getSnapshot(in context: Context, completion: @escaping (DDayWidgetEntry) -> Void) {
        completion(DDayWidgetEntry(date: .now, snapshot: DaySurfaceSnapshotStore.load()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DDayWidgetEntry>) -> Void) {
        let now = Date()
        let entry = DDayWidgetEntry(date: now, snapshot: DaySurfaceSnapshotStore.load())
        let nextRefresh = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 5),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(60 * 60)

        completion(Timeline(entries: [entry], policy: .after(nextRefresh)))
    }
}

struct DDayLockScreenWidget: Widget {
    static let kind = DaySurfaceConstants.lockScreenWidgetKind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: Self.kind, provider: DDayTimelineProvider()) { entry in
            DDayLockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("D-Day")
        .description("잠금화면에서 대표 일정을 확인합니다.")
        .supportedFamilies([
            .accessoryInline,
            .accessoryCircular,
            .accessoryRectangular,
            .systemSmall
        ])
    }
}

private struct DDayLockScreenWidgetView: View {
    @Environment(\.widgetFamily) private var family

    let entry: DDayWidgetEntry

    var body: some View {
        switch family {
        case .accessoryInline:
            Label(entry.snapshot.inlineText, systemImage: "calendar")

        case .accessoryCircular:
            VStack(spacing: 2) {
                Image(systemName: entry.snapshot.symbolName)
                    .font(.caption.weight(.bold))
                    .widgetAccentable()

                Text(entry.snapshot.ddayText)
                    .font(.caption2.weight(.black))
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }

        case .accessoryRectangular:
            VStack(alignment: .leading, spacing: 3) {
                Text(entry.snapshot.eventTitle)
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)

                Text(entry.snapshot.ddayText)
                    .font(.title3.weight(.black))
                    .lineLimit(1)
                    .widgetAccentable()

                Text(entry.snapshot.daysText)
                    .font(.caption2)
                    .lineLimit(1)
            }

        default:
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: entry.snapshot.symbolName)
                        .font(.headline.weight(.bold))
                        .foregroundStyle(Color(hex: entry.snapshot.colorHex))

                    Spacer()

                    Text(entry.snapshot.daysText)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text(entry.snapshot.eventTitle)
                    .font(.headline)
                    .lineLimit(2)

                Text(entry.snapshot.ddayText)
                    .font(.system(size: 32, weight: .black, design: .rounded))
                    .lineLimit(1)
                    .foregroundStyle(Color(hex: entry.snapshot.colorHex))
            }
            .containerBackground(for: .widget) {
                LinearGradient(
                    colors: [
                        Color(hex: "FFF8FA"),
                        Color(hex: entry.snapshot.colorHex).opacity(0.22)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
}

private extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let red: UInt64
        let green: UInt64
        let blue: UInt64
        let alpha: UInt64

        switch sanitized.count {
        case 3:
            red = (value >> 8) * 17
            green = ((value >> 4) & 0xF) * 17
            blue = (value & 0xF) * 17
            alpha = 255
        case 6:
            red = value >> 16
            green = (value >> 8) & 0xFF
            blue = value & 0xFF
            alpha = 255
        case 8:
            red = value >> 24
            green = (value >> 16) & 0xFF
            blue = (value >> 8) & 0xFF
            alpha = value & 0xFF
        default:
            red = 255
            green = 107
            blue = 138
            alpha = 255
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
