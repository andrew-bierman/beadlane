import XCTest
@testable import Beadazzle

final class KanbanBoardPolicyTests: XCTestCase {
    func testColumnsKeepEmptyConfiguredStatusesAndUnrecognizedIssueStatuses() {
        XCTAssertEqual(
            KanbanBoardPolicy.columns(available: ["open", "in_progress", "closed"], issueStatuses: ["open", "review", "review"]) { _ in .uncategorized },
            ["open", "in_progress", "closed", "review"]
        )
    }

    func testColumnsPutCompletedStatusesAfterActiveAndCustomWorkflows() {
        let categories: [String: BeadStatusCategory] = [
            "open": .active, "closed": .done, "review": .wip, "paused": .frozen
        ]
        XCTAssertEqual(
            KanbanBoardPolicy.columns(available: ["open", "closed", "paused", "review"], issueStatuses: []) {
                categories[$0] ?? .uncategorized
            },
            ["open", "review", "paused", "closed"]
        )
    }

    func testInProgressPrecedesBlockedWhenTheyShareACategory() {
        XCTAssertEqual(
            KanbanBoardPolicy.columns(available: ["blocked", "in_progress"], issueStatuses: []) { _ in .wip },
            ["in_progress", "blocked"]
        )
    }
}
