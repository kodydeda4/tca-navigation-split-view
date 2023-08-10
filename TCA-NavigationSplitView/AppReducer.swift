import SwiftUI
import ComposableArchitecture

struct AppReducer: Reducer {
  struct State: Equatable {
    var screenA = ScreenA.State()
    var screenB = ScreenB.State()
    var screenC = ScreenC.State()
    
    @BindingState var destinationTag: DestinationTag? = .screenA
    
    enum DestinationTag: String, Identifiable, Equatable, CaseIterable {
      var id: Self { self }
      case screenA = "Screen A"
      case screenB = "Screen B"
      case screenC = "Screen C"
    }
  }
  enum Action: BindableAction, Equatable {
    case screenA(ScreenA.Action)
    case screenB(ScreenB.Action)
    case screenC(ScreenC.Action)
    case setDestinationTag(State.DestinationTag)
    case binding(BindingAction<State>)
  }
  var body: some ReducerOf<Self> {
    BindingReducer()
    Scope(state: \.screenA, action: /Action.screenA) {
      ScreenA()
    }
    Scope(state: \.screenB, action: /Action.screenB) {
      ScreenB()
    }
    Scope(state: \.screenC, action: /Action.screenC) {
      ScreenC()
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
          ScreenAView(store: store.scope(state: \.screenA, action: AppReducer.Action.screenA))
        case .screenB:
          ScreenBView(store: store.scope(state: \.screenB, action: AppReducer.Action.screenB))
        case .screenC:
          ScreenCView(store: store.scope(state: \.screenC, action: AppReducer.Action.screenC))
        case .none:
          EmptyView()
        }
      } detail: {
        switch viewStore.destinationTag {
        case .screenA:
          ScreenAParentDetailView(store: store.scope(state: \.screenA, action: AppReducer.Action.screenA))
        case .screenB:
          ScreenBParentDetailView(store: store.scope(state: \.screenB, action: AppReducer.Action.screenB))
        case .screenC:
          ScreenCParentDetailView(store: store.scope(state: \.screenC, action: AppReducer.Action.screenC))
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
