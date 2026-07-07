import Foundation

struct Crossing: Identifiable, Codable, Equatable {
    let id: UUID
    var route: String
    var fare: Double
    var date: Date
    var createdAt: Date

    init(id: UUID = UUID(), route: String = "", fare: Double = 0, date: Date = Date(), createdAt: Date = Date()) {
        self.id = id
        self.route = route
        self.fare = fare
        self.date = date
        self.createdAt = createdAt
    }
}
