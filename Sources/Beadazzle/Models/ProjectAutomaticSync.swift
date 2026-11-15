import Foundation

enum ProjectAutomaticSyncMode: String, CaseIterable, Identifiable {
    case off
    case pull
    case sync

    var id: Self { self }

    var title: String {
        switch self {
        case .off: "Off"
        case .pull: "Pull only"
        case .sync: "Pull and push"
        }
    }
}

enum ProjectAutomaticSyncPolicy {
    static let interval: TimeInterval = 5 * 60

    static func shouldRun(
        mode: ProjectAutomaticSyncMode,
        isActive: Bool,
        canSynchronize: Bool,
        isPaused: Bool,
        now: Date,
        nextAttempt: Date
    ) -> Bool {
        mode != .off && isActive && canSynchronize && !isPaused && now >= nextAttempt
    }
}
