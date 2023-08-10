import SwiftUI
import ComposableArchitecture

struct SportList: Reducer {
  struct State: Equatable {
    var people = IdentifiedArrayOf<Sport>(uniqueElements: Sport.defaults)
    var destination: SportDetails.State?
  }
  
  enum Action: Equatable {
    case showDetails(for: Sport)
    case destination(SportDetails.Action)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case let .showDetails(for: sport):
        if let sport = state.people[id: sport.id] {
          state.destination = .init(sport: sport)
        }
        return .none
        
      default:
        return .none
      }
    }
  }
}

// MARK: - SwiftUI

struct SportListView: View {
  let store: StoreOf<SportList>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack {
        List {
          ForEach(viewStore.people) { sport in
            Button(action: {
              viewStore.send(.showDetails(for: sport))
            }) {
              Text("\(sport.name)")
                .fontWeight(.semibold)
                .foregroundColor(viewStore.destination?.sport.id == sport.id ? .accentColor : .secondary)
            }
          }
        }
        .navigationTitle("Sports")
        .toolbar {
          Button("Sports") {
            //...
          }
        }
      }
    }
  }
}

struct SportListDetailView: View {
  let store: StoreOf<SportList>
  
  var body: some View {
    IfLetStore(
      store.scope(state: \.destination, action: SportList.Action.destination),
      then: SportDetailsView.init(store:),
      else: EmptyDetailView.init
    )
  }
}

// MARK: - SwiftUI Previews

struct SportListView_Previews: PreviewProvider {
  static let store = Store(
    initialState: SportList.State(),
    reducer: SportList.init
  )
  static var previews: some View {
    NavigationSplitView {
      EmptyView()
    } content: {
      SportListView(store: Self.store)
    } detail: {
      SportListDetailView(store: Self.store)
    }
    .previewInterfaceOrientation(.landscapeLeft)
  }
}
