import SwiftUI
import ComposableArchitecture

struct ScreenC: Reducer {
  struct State: Equatable {
    var people = IdentifiedArrayOf<Person>(uniqueElements: [
      .init(id: .init(), name: "Kody"),
      .init(id: .init(), name: "Jesse"),
      .init(id: .init(), name: "Grayson"),
      .init(id: .init(), name: "Ethan"),
      .init(id: .init(), name: "Greg"),
    ])
    var destination: ScreenCDetails.State?
  }
  enum Action: Equatable {
    case showDetails(for: Person)
    case destination(ScreenCDetails.Action)
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

struct ScreenCView: View {
  let store: StoreOf<ScreenC>
  
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
    .navigationTitle("Screen C")
  }
}

struct ScreenCParentDetailView: View {
  let store: StoreOf<ScreenC>
  
  var body: some View {
    Group {
      IfLetStore(store.scope(state: \.destination, action: ScreenC.Action.destination)) { store in
        ScreenCDetailView(store: store)
      } else: {
        Text("Nothing Selected")
          .font(.title)
          .foregroundStyle(.secondary)
      }
    }
    .navigationTitle("Screen C Details")
  }
}

// MARK: - SwiftUI Previews

struct ScreenCView_Previews: PreviewProvider {
  static let store = Store(initialState: ScreenC.State(), reducer: ScreenC.init)
  
  static var previews: some View {
    NavigationSplitView {
      EmptyView()
    } content: {
      ScreenCView(store: Self.store)
    } detail: {
      ScreenCParentDetailView(store: Self.store)
    }
    .previewInterfaceOrientation(.landscapeLeft)
  }
}
