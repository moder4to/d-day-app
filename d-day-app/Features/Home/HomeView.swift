import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [CoupleProfile]
    @Query(sort: \DayEvent.targetDate, order: .forward) private var events: [DayEvent]

    @State private var isShowingEditor = false
    @State private var editingEvent: DayEvent?

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("우리의 날")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("D-Day 추가")
                }
            }
            .sheet(isPresented: $isShowingEditor) {
                EventEditorView()
            }
            .sheet(item: $editingEvent) { event in
                EventEditorView(event: event)
            }
        }
    }

    private var content: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                HeroSection(profile: profiles.first, pinnedEvent: pinnedEvent)

                if events.isEmpty {
                    emptyState
                } else {
                    eventList
                }
            }
            .padding(20)
        }
    }

    private var eventList: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("다가오는 날", systemImage: "calendar")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Text("\(events.count)개")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            ForEach(sortedEvents) { event in
                Button {
                    editingEvent = event
                } label: {
                    EventCard(event: event)
                }
                .buttonStyle(.plain)
                .contextMenu {
                    Button {
                        editingEvent = event
                    } label: {
                        Label("수정", systemImage: "pencil")
                    }

                    Button(role: .destructive) {
                        modelContext.delete(event)
                        try? modelContext.save()
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                }
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("아직 등록된 날이 없어요", systemImage: "heart.text.square")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text("생일, 여행, 처음 만난 날처럼 자주 보고 싶은 날짜를 추가해보세요.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)

            Button {
                isShowingEditor = true
            } label: {
                Label("D-Day 추가", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var sortedEvents: [DayEvent] {
        let now = Date()

        return events.sorted { lhs, rhs in
            let lhsValue = DayCounter.eventSortValue(
                targetDate: lhs.targetDate,
                repeatRule: lhs.repeatRule,
                from: now
            )
            let rhsValue = DayCounter.eventSortValue(
                targetDate: rhs.targetDate,
                repeatRule: rhs.repeatRule,
                from: now
            )

            if lhsValue == rhsValue {
                return lhs.title.localizedCompare(rhs.title) == .orderedAscending
            }

            return lhsValue < rhsValue
        }
    }

    private var pinnedEvent: DayEvent? {
        sortedEvents.first { $0.isPinned } ?? sortedEvents.first
    }
}

private struct HeroSection: View {
    let profile: CoupleProfile?
    let pinnedEvent: DayEvent?

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(coupleTitle)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(AppTheme.textPrimary)

                    if let profile {
                        Text(profile.startedAt, format: .dateTime.year().month().day())
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                }

                Spacer()

                Image(systemName: "heart.fill")
                    .font(.title2)
                    .foregroundStyle(AppTheme.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(daysText)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primary)

                Text("함께한 시간")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            if let pinnedEvent {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Label(
                        pinnedEvent.isPinned ? "고정된 날" : "가장 가까운 날",
                        systemImage: pinnedEvent.isPinned ? "pin.fill" : "sparkles"
                    )
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.secondary)

                    HStack(alignment: .lastTextBaseline) {
                        Text(pinnedEvent.title)
                            .font(.headline)
                            .foregroundStyle(AppTheme.textPrimary)

                        Spacer()

                        Text(DayCounter.ddayText(
                            for: pinnedEvent.targetDate,
                            repeatRule: pinnedEvent.repeatRule
                        ))
                        .font(.title3.weight(.bold))
                        .foregroundStyle(Color(hex: pinnedEvent.colorHex))
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [
                    AppTheme.surface,
                    AppTheme.primary.opacity(0.12),
                    AppTheme.secondary.opacity(0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var coupleTitle: String {
        guard let profile else {
            return "우리의 날"
        }

        let first = profile.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let partner = profile.partnerName.trimmingCharacters(in: .whitespacesAndNewlines)

        if first.isEmpty && partner.isEmpty {
            return "우리의 날"
        }

        if first.isEmpty {
            return partner
        }

        if partner.isEmpty {
            return first
        }

        return "\(first) & \(partner)"
    }

    private var daysText: String {
        guard let profile else {
            return "1일째"
        }

        return "\(DayCounter.daysIncludingStart(from: profile.startedAt))일째"
    }
}

private struct EventCard: View {
    let event: DayEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                Label(event.kind.title, systemImage: event.kind.symbolName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.secondary)

                Spacer()

                if event.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundStyle(AppTheme.primary)
                        .accessibilityLabel("고정됨")
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(event.title)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.textPrimary)

                HStack(spacing: 8) {
                    Text(displayDate, format: .dateTime.year().month().day())
                        .font(.subheadline)
                        .foregroundStyle(AppTheme.textSecondary)

                    if event.repeatRule == .yearly {
                        Text("매년")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(AppTheme.secondary.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }

            Text(DayCounter.ddayText(for: event.targetDate, repeatRule: event.repeatRule))
                .font(.system(size: 42, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: event.colorHex))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(18)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 14, x: 0, y: 8)
    }

    private var displayDate: Date {
        DayCounter.displayDate(for: event.targetDate, repeatRule: event.repeatRule)
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [
            CoupleProfile.self,
            DayEvent.self
        ], inMemory: true)
}
