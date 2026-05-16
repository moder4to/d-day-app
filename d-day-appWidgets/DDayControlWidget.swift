import AppIntents
import SwiftUI
import WidgetKit

struct DDayControlWidget: ControlWidget {
    static let kind = DaySurfaceConstants.controlWidgetKind

    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: Self.kind, provider: Provider()) { snapshot in
            ControlWidgetButton(action: OpenDdayAppIntent()) {
                Label(snapshot.ddayText, systemImage: snapshot.symbolName)
            }
        }
        .displayName("D-Day")
        .description("대표 D-Day를 확인하고 앱을 엽니다.")
    }
}

private extension DDayControlWidget {
    struct Provider: ControlValueProvider {
        var previewValue: DaySurfaceSnapshot {
            .placeholder
        }

        func currentValue() async throws -> DaySurfaceSnapshot {
            DaySurfaceSnapshotStore.load()
        }
    }
}
