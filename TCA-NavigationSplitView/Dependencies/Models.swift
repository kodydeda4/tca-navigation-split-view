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
  
  static let baseball = Self(id: .init(), name: "Baseball")
  static let softball = Self(id: .init(), name: "Softball")
  
  static let defaults: [Self] = [
    .baseball,
    .softball
  ]
}

struct Activity: Identifiable, Equatable {
  let id: UUID
  let sportId: UUID
  let name: String
  
  static let defaults: [Self] = [
    .init(id: .init(), sportId: Sport.baseball.id, name: "Hitting"),
    .init(id: .init(), sportId: Sport.baseball.id, name: "Pitching"),
    .init(id: .init(), sportId: Sport.softball.id, name: "Kicking"),
    .init(id: .init(), sportId: Sport.softball.id, name: "Dodging"),
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

