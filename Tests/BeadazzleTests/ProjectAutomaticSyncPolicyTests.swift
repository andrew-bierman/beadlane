import XCTest
@testable import Beadazzle

final class ProjectAutomaticSyncPolicyTests: XCTestCase {
    func testAutomaticSyncRequiresOptInActiveAndIdleProjectAndElapsedInterval() {
        let now = Date(timeIntervalSince1970: 1_000)
        func decision(_ mode: ProjectAutomaticSyncMode, _ active: Bool = true,
                      _ canSync: Bool = true, _ paused: Bool = false,
                      _ next: Date? = nil) -> Bool {
            ProjectAutomaticSyncPolicy.shouldRun(mode: mode, isActive: active,
                canSynchronize: canSync, isPaused: paused, now: now,
                nextAttempt: next ?? now)
        }
        XCTAssertFalse(decision(.off))
        XCTAssertFalse(decision(.pull, false))
        XCTAssertFalse(decision(.pull, true, false))
        XCTAssertFalse(decision(.sync, true, true, true))
        XCTAssertFalse(decision(.sync, true, true, false, now.addingTimeInterval(1)))
        XCTAssertTrue(decision(.pull))
        XCTAssertTrue(decision(.sync))
    }
}
