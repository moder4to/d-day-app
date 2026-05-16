import WidgetKit

enum SystemSurfaceSync {
    static func sync(profiles: [CoupleProfile], events: [DayEvent]) {
        let snapshot = DaySurfaceSnapshotFactory.make(profiles: profiles, events: events)
        DaySurfaceSnapshotStore.save(snapshot)

        WidgetCenter.shared.reloadTimelines(ofKind: DaySurfaceConstants.lockScreenWidgetKind)
        ControlCenter.shared.reloadControls(ofKind: DaySurfaceConstants.controlWidgetKind)
    }
}
