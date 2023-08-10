import SwiftUI
import ComposableArchitecture

struct AppReducer: Reducer {
  struct State: Equatable {
    var players = PlayerList.State()
    var sports = SportList.State()
    var sessions = SessionList.State()
    
    @BindingState var destinationTag: DestinationTag? = .players
    
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
  enum Action: BindableAction, Equatable {
    case players(PlayerList.Action)
    case sports(SportList.Action)
    case sessions(SessionList.Action)
    case setDestinationTag(State.DestinationTag)
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
    Reduce { state, action in
      switch action {
        
      case let .setDestinationTag(value):
        state.destinationTag = value
        return .none
        
      default:
        return .none
      }
    }
  }
}

// MARK: - SwiftUI

struct AppView: View {
  let store: StoreOf<AppReducer>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationSplitView {
        NavigationStack {
          List(selection: viewStore.$destinationTag) {
            ForEach(AppReducer.State.DestinationTag.allCases) { value in
              NavigationLink(value: value) {
                Label(value.label.title, systemImage: value.label.systemImage)
              }
            }
          }
          .navigationTitle("PocketRadar")
        }
      } content: {
        switch viewStore.destinationTag {
        case .players:
          PlayerListView(store: store.scope(state: \.players, action: AppReducer.Action.players))
        case .sports:
          SportListView(store: store.scope(state: \.sports, action: AppReducer.Action.sports))
        case .sessions:
          SessionListView(store: store.scope(state: \.sessions, action: AppReducer.Action.sessions))
        case .none:
          EmptyView()
        }
      } detail: {
        switch viewStore.destinationTag {
        case .players:
          PlayerListDetailView(store: store.scope(state: \.players, action: AppReducer.Action.players))
        case .sports:
          SportListDetailView(store: store.scope(state: \.sports, action: AppReducer.Action.sports))
        case .sessions:
          SessionListDetailView(store: store.scope(state: \.sessions, action: AppReducer.Action.sessions))
        case .none:
          EmptyView()
        }
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
