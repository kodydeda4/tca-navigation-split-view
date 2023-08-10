import Foundation

struct Player: Identifiable, Equatable {
  let id: UUID
  let name: String
  
  static let defaults: [Self] = [
    .init(id: .init(), name: "Kody"),
    .init(id: .init(), name: "Jesse"),
    .init(id: .init(), name: "Grayson"),
    .init(id: .init(), name: "Ethan"),
    .init(id: .init(), name: "Greg"),
  ]
}

struct Sport: Identifiable, Equatable {
  let id: UUID
  let name: String
  
  static let defaults: [Self] = [
    .init(id: .init(), name: "Baseball"),
    .init(id: .init(), name: "Softball"),
  ]
} 

struct Session: Identifiable, Equatable {
  let id: UUID
  let measurements: [Measurement<UnitSpeed>]
  
  static let defaults: [Self] = [
    .init(id: .init(), measurements: [
      .init(value: .random(in: 1...10), unit: .milesPerHour),
      .init(value: .random(in: 1...10), unit: .milesPerHour),
      .init(value: .random(in: 1...10), unit: .milesPerHour),
    ]),
    .init(id: .init(), measurements: [
      .init(value: .random(in: 1...10), unit: .milesPerHour),
      .init(value: .random(in: 1...10), unit: .milesPerHour),
      .init(value: .random(in: 1...10), unit: .milesPerHour),
    ]),
  ]
}

struct LabelValue: Equatable {
  let title: String
  let systemImage: String
}

