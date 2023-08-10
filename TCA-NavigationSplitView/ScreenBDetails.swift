import SwiftUI
import ComposableArchitecture

struct ScreenBDetails: Reducer {
  struct State: Equatable {
    let person: Person
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

struct ScreenBDetailView: View {
  let store: StoreOf<ScreenBDetails>
  
  var body: some View {
    WithViewStore(self.store, observe: { $0 }) { viewStore in
      Text(viewStore.person.name)
    }
    .navigationTitle("Screen B Details")
  }
}
