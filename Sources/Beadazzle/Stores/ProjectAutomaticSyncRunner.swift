import Foundation

/// One loop per workspace. The existing sync action owns serialization, cancellation,
/// validation and snapshot reconciliation; this loop only decides when to request it.
@MainActor
enum ProjectAutomaticSyncRunner {
    static func run(
        store: BeadStore,
        projectURL: URL?,
        interval: TimeInterval = ProjectAutomaticSyncPolicy.interval,
        checkDelay: Duration = .seconds(10)
    ) async {
        guard let projectURL else { return }
        var lastMode = ProjectAutomaticSyncMode.off
        var nextAttempt = Date.distantFuture

        while !Task.isCancelled, store.projectURL == projectURL {
            let mode = store.automaticSyncMode
            let now = Date()
            if mode != lastMode {
                lastMode = mode
                nextAttempt = now.addingTimeInterval(interval)
            }
            if ProjectAutomaticSyncPolicy.shouldRun(
                mode: mode,
                isActive: store.isWorkspaceSceneActive,
                canSynchronize: store.canSynchronizeProjectIssues,
                isPaused: store.automaticSyncPausedAfterFailure,
                now: now,
                nextAttempt: nextAttempt
            ) {
                nextAttempt = now.addingTimeInterval(interval)
                let succeeded: Bool
                switch mode {
                case .off:
                    succeeded = true
                case .pull:
                    succeeded = await store.pullProjectIssues(
                        reportsFailureInWorkspace: true,
                        announcesCompletion: false
                    )
                case .sync:
                    succeeded = await store.synchronizeProjectIssues(
                        reportsFailureInWorkspace: true,
                        announcesCompletion: false
                    )
                }
                if !Task.isCancelled, store.projectURL == projectURL {
                    if succeeded {
                        store.automaticSyncLastSuccessAt = Date()
                    } else if store.automaticSyncMode == mode {
                        store.automaticSyncPausedAfterFailure = true
                    }
                }
            }
            do {
                try await Task.sleep(for: checkDelay)
            } catch {
                return
            }
        }
    }
}
