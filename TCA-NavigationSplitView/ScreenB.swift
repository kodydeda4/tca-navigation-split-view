import SwiftUI
import ComposableArchitecture

struct ScreenB: Reducer {
  struct State: Equatable {
    var people = IdentifiedArrayOf<Person>(uniqueElements: [
      .init(id: .init(), name: "Kody"),
      .init(id: .init(), name: "Jesse"),
      .init(id: .init(), name: "Grayson"),
      .init(id: .init(), name: "Ethan"),
      .init(id: .init(), name: "Greg"),
    ])
    var destination: ScreenBDetails.State?
  }
  enum Action: Equatable {
    case showDetails(for: Person)
    case destination(ScreenBDetails.Action)
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

struct ScreenBView: View {
  let store: StoreOf<ScreenB>
  
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
    .navigationTitle("Screen B")
  }
}

struct ScreenBParentDetailView: View {
  let store: StoreOf<ScreenB>
  
  var body: some View {
    Group {
      IfLetStore(store.scope(state: \.destination, action: ScreenB.Action.destination)) { store in
        ScreenBDetailView(store: store)
      } else: {
        Text("Nothing Selected")
          .font(.title)
          .foregroundStyle(.secondary)
      }
    }
    .navigationTitle("Screen B Details")
  }
}

// MARK: - SwiftUI Previews

struct ScreenBView_Previews: PreviewProvider {
  static let store = Store(initialState: ScreenB.State(), reducer: ScreenB.init)
  
  static var previews: some View {
    NavigationSplitView {
      EmptyView()
    } content: {
      ScreenBView(store: Self.store)
    } detail: {
      ScreenBParentDetailView(store: Self.store)
    }
    .previewInterfaceOrientation(.landscapeLeft)
  }
}
