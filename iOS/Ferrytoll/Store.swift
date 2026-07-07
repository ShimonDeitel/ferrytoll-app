import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [Crossing] = []
    @Published var isPro: Bool = false

    // Free-tier limit is intentionally well above the seed data count (3)
    // so a fresh install never hits the paywall immediately.
    static let freeLimit = 40

    private let fileURL: URL

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        fileURL = dir.appendingPathComponent("ferrytoll_items.json")
        load()
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    func add(_ item: Crossing) {
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: Crossing) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: Crossing) {
        items.removeAll { $0.id == item.id }
        save()
    }

    private func load() {
        if let data = try? Data(contentsOf: fileURL),
           let decoded = try? JSONDecoder().decode([Crossing].self, from: data) {
            items = decoded
        } else {
            items = Self.seedData()
        }
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    static func seedData() -> [Crossing] {
        [
            Crossing(route: "Sample A", fare: 12.5, date: Date().addingTimeInterval(-259200)),
            Crossing(route: "Sample B", fare: 8.0, date: Date().addingTimeInterval(-518400)),
            Crossing(route: "Sample C", fare: 21.75, date: Date().addingTimeInterval(-777600))
        ]
    }
}
