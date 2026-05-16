import SwiftData
import SwiftUI
import UserNotifications

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [CoupleProfile]
    @Query(sort: \DayEvent.targetDate, order: .forward) private var events: [DayEvent]

    @State private var firstName = ""
    @State private var partnerName = ""
    @State private var startedAt = Date()
    @State private var memo = ""
    @State private var authorizationStatus: UNAuthorizationStatus = .notDetermined

    @AppStorage(NotificationSettingsStore.enabledKey) private var notificationsEnabled = false
    @AppStorage(NotificationSettingsStore.onDayKey) private var notifyOnDay = true
    @AppStorage(NotificationSettingsStore.oneDayBeforeKey) private var notifyOneDayBefore = true
    @AppStorage(NotificationSettingsStore.sevenDaysBeforeKey) private var notifySevenDaysBefore = false
    @AppStorage(NotificationSettingsStore.hourKey) private var notificationHour = 9

    var body: some View {
        NavigationStack {
            Form {
                Section("프로필") {
                    TextField("내 이름", text: $firstName)
                    TextField("상대 이름", text: $partnerName)

                    DatePicker(
                        "시작일",
                        selection: $startedAt,
                        displayedComponents: .date
                    )

                    Text("오늘은 \(DayCounter.daysIncludingStart(from: startedAt))일째")
                        .foregroundStyle(AppTheme.secondary)
                }

                Section("메모") {
                    TextField("메모를 입력하세요", text: $memo, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                notificationSection

                Section {
                    Button {
                        saveProfile()
                    } label: {
                        Label("저장", systemImage: "checkmark")
                    }
                    .disabled(!canSave)
                }

                Section("앱 정보") {
                    LabeledContent("이름", value: "D-Day")
                    LabeledContent("저장 방식", value: "기기 내 로컬 저장")
                    LabeledContent("빠른 확인", value: "위젯, 제어센터")
                }
            }
            .navigationTitle("설정")
            .tint(AppTheme.primary)
            .onAppear {
                loadProfile()
                refreshAuthorizationStatus()
            }
            .onChange(of: notificationSignature) {
                Task {
                    await NotificationScheduler.rescheduleAll(events: events)
                }
            }
        }
    }

    private var notificationSection: some View {
        Section("알림") {
            LabeledContent("권한", value: authorizationText)

            Toggle(
                "알림 사용",
                isOn: Binding(
                    get: { notificationsEnabled },
                    set: { newValue in
                        notificationsEnabled = newValue
                        Task {
                            await handleNotificationsEnabledChange(newValue)
                        }
                    }
                )
            )

            if notificationsEnabled {
                Toggle("D-Day 당일", isOn: $notifyOnDay)
                Toggle("하루 전", isOn: $notifyOneDayBefore)
                Toggle("7일 전", isOn: $notifySevenDaysBefore)

                Stepper(
                    "알림 시간 \(notificationHour):00",
                    value: $notificationHour,
                    in: 0...23
                )

                Button {
                    Task {
                        await NotificationScheduler.rescheduleAll(events: events)
                        refreshAuthorizationStatus()
                    }
                } label: {
                    Label("알림 다시 예약", systemImage: "bell.badge")
                }
            }
        }
    }

    private var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !partnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var notificationSignature: String {
        [
            String(notificationsEnabled),
            String(notifyOnDay),
            String(notifyOneDayBefore),
            String(notifySevenDaysBefore),
            String(notificationHour)
        ].joined(separator: "|")
    }

    private var authorizationText: String {
        switch authorizationStatus {
        case .authorized:
            return "허용됨"
        case .denied:
            return "거부됨"
        case .notDetermined:
            return "요청 전"
        case .provisional:
            return "임시 허용"
        case .ephemeral:
            return "일시 허용"
        @unknown default:
            return "확인 필요"
        }
    }

    private func loadProfile() {
        guard let profile = profiles.first else {
            return
        }

        firstName = profile.firstName
        partnerName = profile.partnerName
        startedAt = profile.startedAt
        memo = profile.memo
    }

    private func saveProfile() {
        let profile = profiles.first ?? CoupleProfile()

        profile.firstName = firstName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.partnerName = partnerName.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.startedAt = startedAt
        profile.memo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        profile.updatedAt = .now

        if profiles.isEmpty {
            modelContext.insert(profile)
        }

        try? modelContext.save()
        SystemSurfaceSync.sync(profiles: profiles.isEmpty ? [profile] : profiles, events: events)
    }

    private func handleNotificationsEnabledChange(_ isEnabled: Bool) async {
        if isEnabled {
            let status = await NotificationScheduler.authorizationStatus()

            if status == .notDetermined {
                let granted = await NotificationScheduler.requestAuthorization()
                notificationsEnabled = granted
            } else if status == .denied {
                notificationsEnabled = false
            }
        }

        await NotificationScheduler.rescheduleAll(events: events)
        refreshAuthorizationStatus()
    }

    private func refreshAuthorizationStatus() {
        Task {
            authorizationStatus = await NotificationScheduler.authorizationStatus()
        }
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: CoupleProfile.self, inMemory: true)
}
