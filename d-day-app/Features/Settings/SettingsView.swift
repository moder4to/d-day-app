import SwiftData
import SwiftUI

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [CoupleProfile]

    @State private var firstName = ""
    @State private var partnerName = ""
    @State private var startedAt = Date()
    @State private var memo = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("커플 정보") {
                    TextField("내 이름", text: $firstName)
                    TextField("상대 이름", text: $partnerName)

                    DatePicker(
                        "만난 날",
                        selection: $startedAt,
                        displayedComponents: .date
                    )

                    Text("오늘은 \(DayCounter.daysIncludingStart(from: startedAt))일째")
                        .foregroundStyle(AppTheme.secondary)
                }

                Section("메모") {
                    TextField("둘만의 문장을 적어보세요", text: $memo, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

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
                    LabeledContent("공유/동기화", value: "다음 버전 후보")
                }
            }
            .navigationTitle("설정")
            .tint(AppTheme.primary)
            .onAppear {
                loadProfile()
            }
        }
    }

    private var canSave: Bool {
        !firstName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
        !partnerName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
    }
}

#Preview {
    SettingsView()
        .modelContainer(for: CoupleProfile.self, inMemory: true)
}
