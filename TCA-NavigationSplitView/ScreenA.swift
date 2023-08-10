import SwiftUI
import ComposableArchitecture

struct ScreenA: Reducer {
  struct State: Equatable {
    var people = IdentifiedArrayOf<Person>(uniqueElements: [
      .init(id: .init(), name: "Kody"),
      .init(id: .init(), name: "Jesse"),
      .init(id: .init(), name: "Grayson"),
      .init(id: .init(), name: "Ethan"),
      .init(id: .init(), name: "Greg"),
    ])
    var destination: ScreenADetails.State?
  }
  enum Action: Equatable {
    case showDetails(for: Person)
    case destination(ScreenADetails.Action)
  }
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case let .showDetails(for: person):
        if let person = state.people[id: person.id] {
          state.destination = .init(person: person)
        }
        return .none
      default:
        return .none
      }
    }
  }
}

// MARK: - SwiftUI

struct ScreenAView: View {
  let store: StoreOf<ScreenA>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      List {
        ForEach(viewStore.people) { person in
          Button(action: {
            viewStore.send(.showDetails(for: person))
          }) {
            Text("\(person.name)")
              .fontWeight(.semibold)
              .foregroundColor(viewStore.destination?.person.id == person.id ? .accentColor : .secondary)
          }
        }
      }
    }
    .navigationTitle("Screen A")
  }
}

struct ScreenAParentDetailView: View {
  let store: StoreOf<ScreenA>
  
  var body: some View {
    Group {
      IfLetStore(store.scope(state: \.destination, action: ScreenA.Action.destination)) { store in
        ScreenADetailView(store: store)
      } else: {
        Text("Nothing Selected")
          .font(.title)
          .foregroundStyle(.secondary)
      }
    }
    .navigationTitle("Screen A Details")
  }
}

// MARK: - SwiftUI Previews

struct ScreenAView_Previews: PreviewProvider {
  static let store = Store(initialState: ScreenA.State(), reducer: ScreenA.init)
  
  static var previews: some View {
    NavigationSplitView {
      EmptyView()
    } content: {
      ScreenAView(store: Self.store)
    } detail: {
      ScreenAParentDetailView(store: Self.store)
    }
    .previewInterfaceOrientation(.landscapeLeft)
  }
}