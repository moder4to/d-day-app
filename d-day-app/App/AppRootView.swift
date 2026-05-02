import SwiftData
import SwiftUI

struct AppRootView: View {
    @Query private var profiles: [CoupleProfile]
    @State private var selectedTab = AppTab.home

    var body: some View {
        if profiles.isEmpty {
            OnboardingView()
        } else {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Label("홈", systemImage: "heart.fill")
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

                            Text("둘만의 첫날을 저장하고 중요한 날들을 차곡차곡 모아보세요.")
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
                                "만난 날",
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
                            Label("시작하기", systemImage: "heart.fill")
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
