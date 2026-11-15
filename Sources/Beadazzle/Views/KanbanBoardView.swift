import SwiftUI

enum KanbanBoardPolicy {
    static func columns(
        available: [String],
        issueStatuses: [String],
        category: (String) -> BeadStatusCategory
    ) -> [String] {
        let names = available + Set(issueStatuses).subtracting(available).sorted()
        func rank(_ category: BeadStatusCategory) -> Int {
            switch category {
            case .active: 0
            case .wip: 1
            case .frozen: 2
            case .uncategorized: 3
            case .done: 4
            }
        }
        let builtInOrder = ["open", "in_progress", "hooked", "blocked", "deferred", "pinned", "closed"]
        return names.enumerated().sorted {
            let left = rank(category($0.element))
            let right = rank(category($1.element))
            guard left == right else { return left < right }
            let leftBuiltIn = builtInOrder.firstIndex(of: $0.element) ?? builtInOrder.count
            let rightBuiltIn = builtInOrder.firstIndex(of: $1.element) ?? builtInOrder.count
            return leftBuiltIn == rightBuiltIn ? $0.offset < $1.offset : leftBuiltIn < rightBuiltIn
        }.map(\.element)
    }
}

struct KanbanBoardView: View {
    @Environment(BeadStore.self) private var store
    let requestSetStatus: (Set<String>, String) -> Void
    let openDetail: (String) -> Void

    private var issues: [BeadIssue] {
        store.workspace.filteredIssueIDs.compactMap { store.issue(with: $0) }
    }

    var body: some View {
        let visibleIssues = issues
        let statuses = KanbanBoardPolicy.columns(
            available: store.availableStatuses,
            issueStatuses: visibleIssues.map(\.status),
            category: store.statusCategory(for:)
        )
        let groups = Dictionary(grouping: visibleIssues, by: \.status)
        ScrollView(.horizontal) {
            HStack(alignment: .top, spacing: 12) {
                ForEach(statuses, id: \.self) { status in
                    KanbanColumnView(status: status, issues: groups[status] ?? [], requestSetStatus: requestSetStatus, openDetail: openDetail)
                }
            }
            .padding(12)
        }
    }

}

private struct KanbanColumnView: View {
    @Environment(BeadStore.self) private var store
    @State private var isDropTargeted = false
    let status: String
    let issues: [BeadIssue]
    let requestSetStatus: (Set<String>, String) -> Void
    let openDetail: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: store.statusSymbol(for: status))
                    .foregroundStyle(store.statusColor(for: status))
                Text(status.replacingOccurrences(of: "_", with: " ").capitalized)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(issues.count)").foregroundStyle(.secondary)
            }
            .font(.caption)
            .padding(.horizontal, 4)
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(issues) { issue in
                        card(issue)
                    }
                }
            }
        }
        .frame(width: 230)
        .frame(maxHeight: .infinity, alignment: .top)
        .padding(8)
        .background(.quaternary.opacity(0.35), in: RoundedRectangle(cornerRadius: 8))
        .overlay {
            RoundedRectangle(cornerRadius: 8)
                .strokeBorder(isDropTargeted ? Color.accentColor : .clear, lineWidth: 2)
                .allowsHitTesting(false)
        }
        .contentShape(Rectangle())
        .onDrop(of: BeadFolderDropHandler.contentTypes, isTargeted: $isDropTargeted) { providers in
            guard store.availableStatuses.contains(status) else { return false }
            return BeadBoardDropHandler.accept(providers, status: status, store: store, requestSetStatus: requestSetStatus)
        }
    }

    @ViewBuilder
    private func card(_ issue: BeadIssue) -> some View {
        let content = Button {
            store.select([issue.id])
        } label: {
            VStack(alignment: .leading, spacing: 6) {
                Text(issue.title).font(.callout).frame(maxWidth: .infinity, alignment: .leading)
                HStack {
                    Text(issue.id)
                    Spacer()
                    Text("P\(issue.priority)")
                    Text(issue.issueType)
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }
            .padding(10)
            .background(store.selectedIDs.contains(issue.id) ? Color.accentColor.opacity(0.16) : Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 6))
        }
        .buttonStyle(.plain)
        .contextMenu {
            Button("Open Details") { openDetail(issue.id) }
            Menu("Set Status") {
                ForEach(store.statusChangeOptions(excluding: issue.status), id: \.self) { status in
                    Button(status) { requestSetStatus([issue.id], status) }
                }
            }
        }
        if let payload = store.beadDragPayload(issueID: issue.id) {
            content.draggable(payload)
        } else {
            content
        }
    }
}
