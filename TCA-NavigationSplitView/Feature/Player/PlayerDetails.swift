import SwiftUI
import ComposableArchitecture

struct PlayerDetails: Reducer {
  struct State: Equatable {
    let player: Player
  }
  
  enum Action: Equatable {
    
  }
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      
      default:
        return .none
        
      }
    }
  }
}

// MARK: - SwiftUI

struct PlayerDetailsView: View {
  let store: StoreOf<PlayerDetails>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      Text("Details")
        .font(.title)
        .foregroundStyle(.secondary)
        .navigationTitle(viewStore.player.name)
    }
  }
}

// MARK: - SwiftUI Previews

struct PlayerDetailsView_Previews: PreviewProvider {
  static let store = Store(
    initialState: PlayerDetails.State(player: .defaults.first!),
    reducer: PlayerDetails.init
  )
  static var previews: some View {
    NavigationSplitView {
      EmptyView()
    } content: {
      EmptyView()
    } detail: {
      PlayerDetailsView(store: Self.store)
    }
    .previewInterfaceOrientation(.landscapeLeft)
  }
}
