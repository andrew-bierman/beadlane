import Foundation

@MainActor
enum BeadBoardDropHandler {
    static func accept(
        _ providers: [NSItemProvider],
        status: String,
        store: BeadStore,
        requestSetStatus: @escaping (Set<String>, String) -> Void
    ) -> Bool {
        let supported = providers.compactMap { provider -> (NSItemProvider, String)? in
            let type = BeadFolderDropHandler.contentTypes
                .map(\.identifier)
                .first(where: provider.hasItemConformingToTypeIdentifier)
            return type.map { (provider, $0) }
        }
        guard !supported.isEmpty, supported.count == providers.count else { return false }

        let collector = BeadFolderDropPayloadCollector(count: supported.count) { payloads in
            guard let payloads else {
                store.lastError = "The dragged beads could not be read."
                return
            }
            guard store.canAcceptBeadDragPayloads(payloads) else {
                store.lastError = "Beads can only be moved within the same project."
                return
            }
            // Recheck after asynchronous decoding: the project or status definitions can change.
            guard store.availableStatuses.contains(status) else { return }
            let ids = Set(payloads.flatMap(\.issueIDs)).filter {
                store.issue(with: $0)?.status != status
            }
            guard !ids.isEmpty else { return }
            requestSetStatus(ids, status)
        }
        for (index, (provider, type)) in supported.enumerated() {
            provider.loadDataRepresentation(forTypeIdentifier: type) { data, _ in
                let payload = data.flatMap { try? JSONDecoder().decode(BeadDragPayload.self, from: $0) }
                Task { @MainActor in collector.receive(payload, at: index) }
            }
        }
        return true
    }
}
