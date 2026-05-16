import SwiftData
import SwiftUI

struct EventEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var events: [DayEvent]

    private let event: DayEvent?

    @State private var title = ""
    @State private var targetDate = Date()
    @State private var kind = AnniversaryKind.anniversary
    @State private var repeatRule = RepeatRule.none
    @State private var note = ""
    @State private var isPinned = false
    @State private var colorHex = ColorPreset.default.hex

    init(event: DayEvent? = nil) {
        self.event = event
        _title = State(initialValue: event?.title ?? "")
        _targetDate = State(initialValue: event?.targetDate ?? Date())
        _kind = State(initialValue: event?.kind ?? .anniversary)
        _repeatRule = State(initialValue: event?.repeatRule ?? .none)
        _note = State(initialValue: event?.note ?? "")
        _isPinned = State(initialValue: event?.isPinned ?? false)
        _colorHex = State(initialValue: event?.colorHex ?? ColorPreset.default.hex)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("기본 정보") {
                    TextField("제목", text: $title)

                    DatePicker(
                        "날짜",
                        selection: $targetDate,
                        displayedComponents: .date
                    )

                    Picker("종류", selection: $kind) {
                        ForEach(AnniversaryKind.allCases) { item in
                            Label(item.title, systemImage: item.symbolName)
                                .tag(item)
                        }
                    }

                    Picker("반복", selection: $repeatRule) {
                        ForEach(RepeatRule.allCases) { rule in
                            Text(rule.title)
                                .tag(rule)
                        }
                    }
                }

                Section("옵션") {
                    Toggle("홈에 고정", isOn: $isPinned)

                    ColorPresetPicker(selectedHex: $colorHex)

                    TextField("메모", text: $note, axis: .vertical)
                        .lineLimit(3, reservesSpace: true)
                }

                if event != nil {
                    Section {
                        Button(role: .destructive) {
                            deleteEvent()
                        } label: {
                            Label("삭제", systemImage: "trash")
                        }
                    }
                }
            }
            .navigationTitle(event == nil ? "일정 추가" : "일정 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        save()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedNote = note.trimmingCharacters(in: .whitespacesAndNewlines)

        if let event {
            if isPinned {
                unpinOtherEvents(except: event)
            }

            event.title = trimmedTitle
            event.targetDate = targetDate
            event.kind = kind
            event.repeatRule = repeatRule
            event.note = trimmedNote
            event.colorHex = colorHex
            event.isPinned = isPinned
            event.updatedAt = .now
        } else {
            let event = DayEvent(
                title: trimmedTitle,
                targetDate: targetDate,
                kind: kind,
                repeatRule: repeatRule,
                note: trimmedNote,
                colorHex: colorHex,
                isPinned: isPinned
            )

            if isPinned {
                unpinOtherEvents(except: event)
            }

            modelContext.insert(event)
        }

        try? modelContext.save()
        Task {
            await NotificationScheduler.rescheduleAll(events: events)
        }
        dismiss()
    }

    private func deleteEvent() {
        if let event {
            NotificationScheduler.cancel(event: event)
            modelContext.delete(event)
            try? modelContext.save()
            Task {
                await NotificationScheduler.rescheduleAll(events: events.filter { $0 !== event })
            }
        }

        dismiss()
    }

    private func unpinOtherEvents(except selectedEvent: DayEvent) {
        for event in events where event !== selectedEvent && event.isPinned {
            event.isPinned = false
            event.updatedAt = .now
        }
    }
}

private struct ColorPresetPicker: View {
    @Binding var selectedHex: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("색상")

            HStack(spacing: 12) {
                ForEach(ColorPreset.all) { preset in
                    Button {
                        selectedHex = preset.hex
                    } label: {
                        ZStack {
                            Circle()
                                .fill(Color(hex: preset.hex))
                                .frame(width: 34, height: 34)

                            if selectedHex == preset.hex {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(preset.name)
                }
            }
        }
    }
}

private struct ColorPreset: Identifiable {
    let id: String
    let name: String
    let hex: String

    static let `default` = ColorPreset(id: "blue", name: "블루", hex: "2F6FED")

    static let all: [ColorPreset] = [
        .default,
        ColorPreset(id: "teal", name: "틸", hex: "0F766E"),
        ColorPreset(id: "violet", name: "바이올렛", hex: "6D5BD0"),
        ColorPreset(id: "mint", name: "민트", hex: "3AAFA9"),
        ColorPreset(id: "amber", name: "앰버", hex: "F5A623")
    ]
}

#Preview {
    EventEditorView()
        .modelContainer(for: DayEvent.self, inMemory: true)
}
