import SwiftUI
import ComposableArchitecture

struct SportDetails: Reducer {
  struct State: Equatable {
    let sport: Sport
    var activities: [Activity] {
      Activity.defaults.filter { $0.sportId == sport.id }
    }
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

struct SportDetailsView: View {
  let store: StoreOf<SportDetails>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List {
        Section("Activities") {
          ForEach(viewStore.activities) { activity in
            Text(activity.name)
          }
        }
      }
      .navigationTitle(viewStore.sport.name)
      .listStyle(.plain)
    }
  }
}

// MARK: - SwiftUI Previews

struct SportDetailsView_Previews: PreviewProvider {
  static let store = Store(
    initialState: SportDetails.State(sport: .defaults.first!),
    reducer: SportDetails.init
  )
  static var previews: some View {
    NavigationSplitView {
      EmptyView()
    } content: {
      EmptyView()
    } detail: {
      SportDetailsView(store: Self.store)
    }
    .previewInterfaceOrientation(.landscapeLeft)
  }
}
