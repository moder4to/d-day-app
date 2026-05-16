import AppIntents

struct OpenDdayAppIntent: AppIntent {
    static var title: LocalizedStringResource = "D-Day 열기"
    static var description = IntentDescription("대표 D-Day를 확인할 수 있도록 앱을 엽니다.")
    static var openAppWhenRun = true

    func perform() async throws -> some IntentResult {
        .result()
    }
}
