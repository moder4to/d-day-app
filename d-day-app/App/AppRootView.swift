import SwiftData
import SwiftUI

struct AppRootView: View {
    @Query private var profiles: [CoupleProfile]
    @Query(sort: \DayEvent.targetDate, order: .forward) private var events: [DayEvent]
    @State private var selectedTab = AppTab.home

    var body: some View {
        Group {
            if profiles.isEmpty {
                OnboardingView()
            } else {
                TabView(selection: $selectedTab) {
                    HomeView()
                        .tabItem {
                            Label("홈", systemImage: "calendar")
                        }
                        .tag(AppTab.home)

                    SettingsView()
                        .tabItem {
                            Label("설정", systemImage: "gearshape.fill")
                        }
                        .tag(AppTab.settings)
                }
                .tint(AppTheme.primary)
            }
        }
        .onAppear {
            syncExternalSurfaces()
        }
        .onChange(of: systemSurfaceSignature) {
            syncExternalSurfaces()
        }
    }

    private var systemSurfaceSignature: String {
        let profileSignature = profiles.map {
            [
                $0.firstName,
                $0.partnerName,
                String($0.startedAt.timeIntervalSince1970),
                $0.memo,
                String($0.updatedAt.timeIntervalSince1970)
            ].joined(separator: "|")
        }

        let eventSignature = events.map {
            [
                $0.title,
                String($0.targetDate.timeIntervalSince1970),
                $0.kindRawValue,
                $0.repeatRuleRawValue,
                $0.note,
                $0.colorHex,
                String($0.isPinned),
                String($0.updatedAt.timeIntervalSince1970)
            ].joined(separator: "|")
        }

        return (profileSignature + eventSignature).joined(separator: "#")
    }

    private func syncExternalSurfaces() {
        SystemSurfaceSync.sync(profiles: profiles, events: events)

        Task {
            await NotificationScheduler.rescheduleAll(events: events)
        }
    }
}

private enum AppTab: Hashable {
    case home
    case settings
}

private struct OnboardingView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var firstName = ""
    @State private var partnerName = ""
    @State private var startedAt = Date()
    @State private var memo = ""

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        AppTheme.background,
                        AppTheme.primary.opacity(0.16),
                        AppTheme.secondary.opacity(0.10)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("D-Day")
                                .font(.system(size: 44, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.textPrimary)

                            Text("시작일과 일정을 저장해 남은 날을 확인하세요.")
                                .font(.body)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                        .padding(.top, 40)

                        VStack(alignment: .leading, spacing: 16) {
                            TextField("내 이름", text: $firstName)
                                .textContentType(.name)
                                .submitLabel(.next)

                            TextField("상대 이름", text: $partnerName)
                                .textContentType(.name)
                                .submitLabel(.next)

                            DatePicker(
                                "시작일",
                                selection: $startedAt,
                                displayedComponents: .date
                            )

                            TextField("메모", text: $memo, axis: .vertical)
                                .lineLimit(3, reservesSpace: true)
                        }
                        .textFieldStyle(.roundedBorder)

                        VStack(alignment: .leading, spacing: 8) {
                            Text("\(DayCounter.daysIncludingStart(from: startedAt))일째")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(AppTheme.primary)

                            Text(startedAt, format: .dateTime.year().month().day())
                                .font(.subheadline)
                                .foregroundStyle(AppTheme.textSecondary)
                        }

                        Button {
                            saveProfile()
                        } label: {
                            Label("시작하기", systemImage: "checkmark")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(AppTheme.primary)
                        .controlSize(.large)
                        .disabled(!canSave)
                    }
                    .padding(24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !partnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func saveProfile() {
        let profile = CoupleProfile(
            firstName: firstName.trimmingCharacters(in: .whitespacesAndNewlines),
            partnerName: partnerName.trimmingCharacters(in: .whitespacesAndNewlines),
            startedAt: startedAt,
            memo: memo.trimmingCharacters(in: .whitespacesAndNewlines)
        )

        modelContext.insert(profile)
        try? modelContext.save()
    }
}

#Preview {
    AppRootView()
        .modelContainer(for: [
            CoupleProfile.self,
            DayEvent.self
        ], inMemory: true)
}
