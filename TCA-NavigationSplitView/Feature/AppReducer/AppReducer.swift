import SwiftUI
import ComposableArchitecture

struct AppReducer: Reducer {
  struct State: Equatable {
    var players = PlayerList.State()
    var sports = SportList.State()
    var sessions = SessionList.State()
    @BindingState var navigationSplitViewVisibility = NavigationSplitViewVisibility.all
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
    if UIDevice.current.userInterfaceIdiom == .phone {
      iPhoneView(store: store)
      //iPadView(store: store)
    } else {
      iPadView(store: store)
    }
  }
}

private struct iPadView: View {
  let store: StoreOf<AppReducer>
  
  struct ViewState: Equatable {
    let navigationSplitViewVisibility: NavigationSplitViewVisibility
    let destinationTag: AppReducer.State.DestinationTag?
    
    init(_ state: AppReducer.State) {
      self.navigationSplitViewVisibility = state.navigationSplitViewVisibility
      self.destinationTag = state.destinationTag
    }
  }

  var body: some View {
    WithViewStore(store, observe: ViewState.init) { viewStore in
      NavigationSplitView(columnVisibility: viewStore.binding(
        get: { $0.navigationSplitViewVisibility },
        send: { .binding(.set(\.$navigationSplitViewVisibility, $0)) }
      )) {
        NavigationStack {
          List(selection: viewStore.binding(
            get: { $0.destinationTag },
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

private struct iPhoneView: View {
  let store: StoreOf<AppReducer>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack {
        List(selection: viewStore.binding(
          get: { $0.destinationTag },
          send: { .binding(.set(\.$destinationTag, $0)) }
        )) {
          ForEach(AppReducer.State.DestinationTag.allCases) { value in
            NavigationLink(value: value) {
              Label(value.label.title, systemImage: value.label.systemImage)
            }
          }
        }
        .navigationTitle("PocketRadar")
        .listStyle(.plain)
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
    //.previewInterfaceOrientation(.landscapeLeft)
  }
}
