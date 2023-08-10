import SwiftUI
import ComposableArchitecture

struct SessionDetails: Reducer {
  struct State: Equatable {
    let session: Session
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

struct SessionDetailsView: View {
  let store: StoreOf<SessionDetails>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack {
        List {
          ForEach(viewStore.session.measurements, id: \.self) { measurement in
            Text("\(Int(measurement.value)) \(measurement.unit.symbol)")
          }
        }
        .navigationTitle("Session Details")
        .toolbar {
          Button("Session Details") {
            //...
          }
        }
      }
    }
  }
}

// MARK: - SwiftUI Previews

struct SessionDetailsView_Previews: PreviewProvider {
  static let store = Store(
    initialState: SessionDetails.State(session: .defaults.first!),
    reducer: SessionDetails.init
  )
  static var previews: some View {
    NavigationSplitView {
      EmptyView()
    } content: {
      EmptyView()
    } detail: {
      SessionDetailsView(store: Self.store)
    }
    .previewInterfaceOrientation(.landscapeLeft)
  }
}
