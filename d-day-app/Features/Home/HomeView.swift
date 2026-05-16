import SwiftData
import SwiftUI

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [CoupleProfile]
    @Query(sort: \DayEvent.targetDate, order: .forward) private var events: [DayEvent]

    @State private var isShowingEditor = false
    @State private var editingEvent: DayEvent?
    @State private var eventPendingDeletion: DayEvent?
    @State private var sortMode = HomeSortMode.smart
    @State private var filter = HomeFilter.all

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                content
            }
            .navigationTitle("D-Day")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingEditor = true
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("일정 추가")
                }
            }
            .sheet(isPresented: $isShowingEditor) {
                EventEditorView()
            }
            .sheet(item: $editingEvent) { event in
                EventEditorView(event: event)
            }
            .confirmationDialog(
                "일정을 삭제할까요?",
                isPresented: Binding(
                    get: { eventPendingDeletion != nil },
                    set: { isPresented in
                        if !isPresented {
                            eventPendingDeletion = nil
                        }
                    }
                ),
                titleVisibility: .visible
            ) {
                Button("삭제", role: .destructive) {
                    if let event = eventPendingDeletion {
                        delete(event)
                    }
                }

                Button("취소", role: .cancel) {}
            } message: {
                if let event = eventPendingDeletion {
                    Text("\(event.title)을 삭제하면 예약된 알림도 취소됩니다.")
                }
            }
        }
    }

    private var content: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 18) {
                HeroSection(profile: profiles.first, pinnedEvent: pinnedEvent)
                SystemSurfacesPreview(profile: profiles.first, pinnedEvent: pinnedEvent)

                if events.isEmpty {
                    emptyState
                } else if displayedEvents.isEmpty {
                    filteredEmptyState
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

                Text("\(displayedEvents.count)개")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)

                Menu {
                    Picker("정렬", selection: $sortMode) {
                        ForEach(HomeSortMode.allCases) { mode in
                            Text(mode.title)
                                .tag(mode)
                        }
                    }
                } label: {
                    Image(systemName: "arrow.up.arrow.down")
                }
                .accessibilityLabel("정렬")

                Menu {
                    Button {
                        filter = .all
                    } label: {
                        Label("전체", systemImage: filter == .all ? "checkmark" : "calendar")
                    }

                    Button {
                        filter = .pinned
                    } label: {
                        Label("고정", systemImage: filter == .pinned ? "checkmark" : "pin.fill")
                    }

                    Divider()

                    ForEach(AnniversaryKind.allCases) { kind in
                        Button {
                            filter = .kind(kind)
                        } label: {
                            Label(kind.title, systemImage: filter == .kind(kind) ? "checkmark" : kind.symbolName)
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
                .accessibilityLabel("필터")
            }

            ForEach(displayedEvents) { event in
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
                        eventPendingDeletion = event
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                }
            }
        }
    }

    private func delete(_ event: DayEvent) {
        NotificationScheduler.cancel(event: event)
        modelContext.delete(event)
        try? modelContext.save()

        let remainingEvents = events.filter { $0 !== event }
        SystemSurfaceSync.sync(profiles: profiles, events: remainingEvents)

        Task {
            await NotificationScheduler.rescheduleAll(events: remainingEvents)
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 14) {
            Label("등록된 일정이 없습니다", systemImage: "calendar.badge.plus")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Text("확인할 날짜를 추가하면 남은 날과 지난 날이 표시됩니다.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.textSecondary)

            Button {
                isShowingEditor = true
            } label: {
                Label("일정 추가", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
            .tint(AppTheme.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var filteredEmptyState: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("표시할 일정이 없습니다", systemImage: "line.3.horizontal.decrease.circle")
                .font(.headline)
                .foregroundStyle(AppTheme.textPrimary)

            Button {
                filter = .all
            } label: {
                Label("전체 보기", systemImage: "calendar")
            }
            .buttonStyle(.bordered)
            .tint(AppTheme.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }

    private var displayedEvents: [DayEvent] {
        let filtered = sortedEvents.filter { event in
            switch filter {
            case .all:
                return true
            case .pinned:
                return event.isPinned
            case .kind(let kind):
                return event.kind == kind
            }
        }

        switch sortMode {
        case .smart:
            return filtered
        case .date:
            return filtered.sorted {
                if $0.targetDate == $1.targetDate {
                    return $0.title.localizedCompare($1.title) == .orderedAscending
                }

                return $0.targetDate < $1.targetDate
            }
        case .title:
            return filtered.sorted {
                $0.title.localizedCompare($1.title) == .orderedAscending
            }
        }
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

private enum HomeSortMode: String, CaseIterable, Identifiable {
    case smart
    case date
    case title

    var id: String {
        rawValue
    }

    var title: String {
        switch self {
        case .smart:
            return "다가오는 순"
        case .date:
            return "날짜순"
        case .title:
            return "이름순"
        }
    }
}

private enum HomeFilter: Equatable {
    case all
    case pinned
    case kind(AnniversaryKind)
}

private struct SystemSurfacesPreview: View {
    let profile: CoupleProfile?
    let pinnedEvent: DayEvent?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("빠른 확인", systemImage: "rectangle.on.rectangle")
                    .font(.headline)
                    .foregroundStyle(AppTheme.textPrimary)

                Spacer()

                Text("iOS 18")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(AppTheme.secondary.opacity(0.12))
                    .clipShape(Capsule())
            }

            LockScreenSurfaceCard(summary: summary)
            ControlCenterSurfaceCard(summary: summary)
        }
        .padding(18)
        .background(AppTheme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        .shadow(color: .black.opacity(0.05), radius: 12, x: 0, y: 8)
    }

    private var summary: SurfaceSummary {
        SurfaceSummary(profile: profile, pinnedEvent: pinnedEvent)
    }
}

private struct LockScreenSurfaceCard: View {
    let summary: SurfaceSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .firstTextBaseline) {
                Text("9:41")
                    .font(.system(size: 38, weight: .semibold, design: .rounded))
                    .lineLimit(1)

                Spacer()

                Text("잠금화면")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white.opacity(0.72))
            }

            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "calendar")
                    Text(summary.inlineText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 10)
                .padding(.vertical, 7)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(.white.opacity(0.14))
                .clipShape(Capsule())

                ZStack {
                    Circle()
                        .fill(.white.opacity(0.14))

                    VStack(spacing: 1) {
                        Image(systemName: summary.symbolName)
                            .font(.caption.weight(.bold))

                        Text(summary.ddayText)
                            .font(.caption2.weight(.black))
                            .lineLimit(1)
                            .minimumScaleFactor(0.65)
                    }
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 3) {
                    Text(summary.eventTitle)
                        .font(.caption.weight(.semibold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.78)

                    Text(summary.ddayText)
                        .font(.title3.weight(.black))
                        .lineLimit(1)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 9)
                .frame(width: 116, height: 58, alignment: .leading)
                .background(.white.opacity(0.14))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding(16)
        .foregroundStyle(.white)
        .background(
            LinearGradient(
                colors: [
                    Color(hex: "111827"),
                    Color(hex: "1F3A5F"),
                    Color(hex: "0F766E")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ControlCenterSurfaceCard: View {
    let summary: SurfaceSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("제어센터")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.textSecondary)

                Spacer()

                Image(systemName: "slider.horizontal.3")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        Image(systemName: summary.symbolName)
                            .font(.callout.weight(.bold))
                            .foregroundStyle(.white)
                            .frame(width: 30, height: 30)
                            .background(summary.eventColor)
                            .clipShape(Circle())

                        Text(summary.eventTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(AppTheme.textPrimary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.78)
                    }

                    HStack(alignment: .lastTextBaseline, spacing: 6) {
                        Text(summary.ddayText)
                            .font(.system(size: 30, weight: .black, design: .rounded))
                            .foregroundStyle(summary.eventColor)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)

                        Text(summary.daysText)
                            .font(.caption.weight(.bold))
                            .foregroundStyle(AppTheme.textSecondary)
                            .lineLimit(1)
                    }
                }
                .padding(14)
                .frame(maxWidth: .infinity, minHeight: 116, alignment: .leading)
                .background(AppTheme.background.opacity(0.82))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

                VStack(spacing: 8) {
                    Image(systemName: "arrow.up.right.circle.fill")
                        .font(.title2)
                        .foregroundStyle(AppTheme.primary)

                    Text("열기")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .frame(width: 78, height: 116)
                .background(AppTheme.background.opacity(0.82))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
        }
        .padding(14)
        .background(.ultraThinMaterial)
        .overlay {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .stroke(.white.opacity(0.65), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct SurfaceSummary {
    let coupleTitle: String
    let daysText: String
    let eventTitle: String
    let ddayText: String
    let symbolName: String
    let eventColor: Color

    init(profile: CoupleProfile?, pinnedEvent: DayEvent?) {
        coupleTitle = SurfaceSummary.coupleTitle(for: profile)

        if let profile {
            daysText = "\(DayCounter.daysIncludingStart(from: profile.startedAt))일째"
        } else {
            daysText = "1일째"
        }

        if let pinnedEvent {
            eventTitle = pinnedEvent.title
            ddayText = DayCounter.ddayText(
                for: pinnedEvent.targetDate,
                repeatRule: pinnedEvent.repeatRule
            )
            symbolName = pinnedEvent.kind.symbolName
            eventColor = Color(hex: pinnedEvent.colorHex)
        } else {
            eventTitle = "첫 D-Day"
            ddayText = "D-Day"
            symbolName = "calendar.badge.plus"
            eventColor = AppTheme.primary
        }
    }

    var inlineText: String {
        "\(coupleTitle) \(daysText)"
    }

    private static func coupleTitle(for profile: CoupleProfile?) -> String {
        guard let profile else {
            return "시작일"
        }

        let first = profile.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let partner = profile.partnerName.trimmingCharacters(in: .whitespacesAndNewlines)

        if first.isEmpty && partner.isEmpty {
            return "시작일"
        }

        if first.isEmpty {
            return partner
        }

        if partner.isEmpty {
            return first
        }

        return "\(first) & \(partner)"
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

                Image(systemName: "calendar")
                    .font(.title2)
                    .foregroundStyle(AppTheme.primary)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(daysText)
                    .font(.system(size: 52, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.primary)

                Text("시작일부터")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(AppTheme.textSecondary)
            }

            if let pinnedEvent {
                Divider()

                VStack(alignment: .leading, spacing: 8) {
                    Label(
                        pinnedEvent.isPinned ? "고정된 날" : "가장 가까운 날",
                        systemImage: pinnedEvent.isPinned ? "pin.fill" : "calendar.badge.clock"
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
            return "시작일"
        }

        let first = profile.firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        let partner = profile.partnerName.trimmingCharacters(in: .whitespacesAndNewlines)

        if first.isEmpty && partner.isEmpty {
            return "시작일"
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
