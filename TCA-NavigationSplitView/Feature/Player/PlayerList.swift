import SwiftUI
import ComposableArchitecture

struct PlayerList: Reducer {
  struct State: Equatable {
    var players = IdentifiedArrayOf<Player>(uniqueElements: Player.defaults)
    var destination: PlayerDetails.State?
  }
  
  enum Action: Equatable {
    case showDetails(for: Player)
    case destination(PlayerDetails.Action)
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case let .showDetails(for: player):
        if let player = state.players[id: player.id] {
          state.destination = .init(player: player)
        }
        return .none
      
      default:
        return .none
        
      }
    }
  }
}

// MARK: - SwiftUI

struct PlayerListView: View {
  let store: StoreOf<PlayerList>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        ForEach(viewStore.players) { player in
          Button(action: {
            viewStore.send(.showDetails(for: player))
          }) {
            Text("\(player.name)")
              .fontWeight(.semibold)
              .foregroundColor(viewStore.destination?.player.id == player.id ? .accentColor : .secondary)
          }
        }
      }
    }
    .navigationTitle("Players")
  }
}

struct PlayerListDetailView: View {
  let store: StoreOf<PlayerList>
  
  var body: some View {
    IfLetStore(
      store.scope(state: \.destination, action: PlayerList.Action.destination),
      then: PlayerDetailsView.init(store:),
      else: EmptyDetailView.init
    )
  }
}

// MARK: - SwiftUI Previews

struct PlayerListView_Previews: PreviewProvider {
  static let store = Store(
    initialState: PlayerList.State(),
    reducer: PlayerList.init
  )
  static var previews: some View {
    NavigationSplitView {
      EmptyView()
    } content: {
      PlayerListView(store: Self.store)
    } detail: {
      PlayerListDetailView(store: Self.store)
    }
    .previewInterfaceOrientation(.landscapeLeft)
  }
}
