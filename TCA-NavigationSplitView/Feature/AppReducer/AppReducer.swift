import SwiftUI
import ComposableArchitecture

struct AppReducer: Reducer {
  struct State: Equatable {
    var players = PlayerList.State()
    var sports = SportList.State()
    var sessions = SessionList.State()
    @BindingState var columnVisibility: NavigationSplitViewVisibility = .all
    @BindingState var destinationTag: DestinationTag? = .sessions
  }
  enum Action: BindableAction, Equatable {
    case players(PlayerList.Action)
    case sports(SportList.Action)
    case sessions(SessionList.Action)
    case binding(BindingAction<State>)
  }
  var body: some ReducerOf<Self> {
    BindingReducer()
    Scope(state: \.players, action: /Action.players) {
      PlayerList()
    }
    Scope(state: \.sports, action: /Action.sports) {
      SportList()
    }
    Scope(state: \.sessions, action: /Action.sessions) {
      SessionList()
    }
  }
}

extension AppReducer.State {
  enum DestinationTag: String, Identifiable, Equatable, CaseIterable {
    var id: Self { self }
    case players = "Players"
    case sports = "Sports"
    case sessions = "Sessions"
  
    var label: LabelValue {
      switch self {
      case .players:
        return .init(title: "Players", systemImage: "person.2")
      case .sports:
        return .init(title: "Sports", systemImage: "baseball")
      case .sessions:
        return .init(title: "Sessions", systemImage: "list.clipboard")
      }
    }
  }
}

// MARK: - SwiftUI

struct AppView: View {
  let store: StoreOf<AppReducer>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationSplitView(columnVisibility: viewStore.$columnVisibility) {
        Sidebar(store: store)
      } content: {
        Content(store: store)
      } detail: {
        Detail(store: store)
      }
    }
  }
}

private struct Sidebar: View {
  let store: StoreOf<AppReducer>

  var body: some View {
    WithViewStore(store, observe: \.destinationTag) { viewStore in
      NavigationStack {
        List(selection: viewStore.binding(
          get: { $0 },
          send: { .binding(.set(\.$destinationTag, $0)) }
        )) {
          ForEach(AppReducer.State.DestinationTag.allCases) { value in
            NavigationLink(value: value) {
              Label(value.label.title, systemImage: value.label.systemImage)
            }
          }
        }
        .navigationTitle("PocketRadar")
      }
    }
  }
}

private struct Content: View {
  let store: StoreOf<AppReducer>
  
  var body: some View {
    WithViewStore(store, observe: \.destinationTag) { viewStore in
      switch viewStore.state {
      case .players:
        PlayerListView(store: store.scope(
          state: \.players,
          action: AppReducer.Action.players
        ))
      case .sports:
        SportListView(store: store.scope(
          state: \.sports,
          action: AppReducer.Action.sports
        ))
      case .sessions:
        SessionListView(store: store.scope(
          state: \.sessions,
          action: AppReducer.Action.sessions
        ))
      case .none:
        EmptyView()
      }
    }
  }
}

private struct Detail: View {
  let store: StoreOf<AppReducer>
  
  var body: some View {
    WithViewStore(store, observe: \.destinationTag) { viewStore in
      switch viewStore.state {
      case .players:
        PlayerListDetailView(store: store.scope(
          state: \.players,
          action: AppReducer.Action.players
        ))
      case .sports:
        SportListDetailView(store: store.scope(
          state: \.sports,
          action: AppReducer.Action.sports
        ))
      case .sessions:
        SessionListDetailView(store: store.scope(
          state: \.sessions,
          action: AppReducer.Action.sessions
        ))
      case .none:
        EmptyView()
      }
    }
  }
}


// MARK: - SwiftUI Previews

struct AppView_Previews: PreviewProvider {
  static let store = Store(
    initialState: AppReducer.State(),
    reducer: AppReducer.init
  )
  static var previews: some View {
    AppView(store: Self.store)
    .previewInterfaceOrientation(.landscapeLeft)
  }
}
