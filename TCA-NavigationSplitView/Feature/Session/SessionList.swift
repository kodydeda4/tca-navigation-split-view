import SwiftUI
import ComposableArchitecture

struct SessionList: Reducer {
  struct State: Equatable {
    let sessions = IdentifiedArrayOf<Session>(uniqueElements: Session.defaults)
    var destination: SessionDetails.State?
  }
  enum Action: Equatable {
    case showDetails(for: Session)
    case destination(SessionDetails.Action)
  }
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case let .showDetails(for: session):
        if let session = state.sessions[id: session.id] {
          state.destination = .init(session: session)
        }
        return .none
        
      default:
        return .none
        
      }
    }
  }
}

// MARK: - SwiftUI

struct SessionListView: View {
  let store: StoreOf<SessionList>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        ForEach(viewStore.sessions) { session in
          Button(action: {
            viewStore.send(.showDetails(for: session))
          }) {
            Text("\(session.id.description.prefix(8).description)")
              .fontWeight(.semibold)
              .foregroundColor(viewStore.destination?.session.id == session.id ? .accentColor : .secondary)
          }
        }
      }
    }
    .navigationTitle("Sessions")
  }
}

struct SessionListDetailView: View {
  let store: StoreOf<SessionList>
  
  var body: some View {
    IfLetStore(
      store.scope(state: \.destination, action: SessionList.Action.destination),
      then: SessionDetailsView.init(store:),
      else: EmptyDetailView.init
    )
  }
}


// MARK: - SwiftUI Previews

struct SessionListView_Previews: PreviewProvider {
  static let store = Store(
    initialState: SessionList.State(),
    reducer: SessionList.init
  )
  static var previews: some View {
    NavigationSplitView {
      EmptyView()
    } content: {
      SessionListView(store: Self.store)
    } detail: {
      SessionListDetailView(store: Self.store)
    }
    .previewInterfaceOrientation(.landscapeLeft)
  }
}
