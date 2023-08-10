import SwiftUI
import ComposableArchitecture

struct AppReducer: Reducer {
  struct State: Equatable {
    var screenA = PlayerList.State()
    var screenB = SportList.State()
    var screenC = SessionList.State()
    
    @BindingState var destinationTag: DestinationTag? = .screenA
    
    enum DestinationTag: String, Identifiable, Equatable, CaseIterable {
      var id: Self { self }
      case screenA = "Screen A"
      case screenB = "Screen B"
      case screenC = "Screen C"
    }
  }
  enum Action: BindableAction, Equatable {
    case screenA(PlayerList.Action)
    case screenB(SportList.Action)
    case screenC(SessionList.Action)
    case setDestinationTag(State.DestinationTag)
    case binding(BindingAction<State>)
  }
  var body: some ReducerOf<Self> {
    BindingReducer()
    Scope(state: \.screenA, action: /Action.screenA) {
      PlayerList()
    }
    Scope(state: \.screenB, action: /Action.screenB) {
      SportList()
    }
    Scope(state: \.screenC, action: /Action.screenC) {
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
          List(
            AppReducer.State.DestinationTag.allCases,
            selection: viewStore.$destinationTag
          ) { destination in
            NavigationLink(value: destination) {
              Label(destination.rawValue, systemImage: "leaf")
            }
          }
          .navigationTitle("Title")
        }
      } content: {
        switch viewStore.destinationTag {
        case .screenA:
          PlayerListView(store: store.scope(state: \.screenA, action: AppReducer.Action.screenA))
        case .screenB:
          SportListView(store: store.scope(state: \.screenB, action: AppReducer.Action.screenB))
        case .screenC:
          SessionListView(store: store.scope(state: \.screenC, action: AppReducer.Action.screenC))
        case .none:
          EmptyView()
        }
      } detail: {
        switch viewStore.destinationTag {
        case .screenA:
          PlayerListDetailView(store: store.scope(state: \.screenA, action: AppReducer.Action.screenA))
        case .screenB:
          SportListDetailView(store: store.scope(state: \.screenB, action: AppReducer.Action.screenB))
        case .screenC:
          SessionListDetailView(store: store.scope(state: \.screenC, action: AppReducer.Action.screenC))
        case .none:
          EmptyView()
        }
      }
    }
  }
}

// MARK: - SwiftUI Previews

struct AppView_Previews: PreviewProvider {
  static var previews: some View {
    AppView(store: Store(
      initialState: AppReducer.State(),
      reducer: AppReducer.init
    ))
    .previewInterfaceOrientation(.landscapeLeft)
  }
}
