# TCA-NavigationSplitView

## About

This demo shows how [ComposableArchitecture](https://github.com/pointfreeco/swift-composable-architecture) (TCA) can be used to power a 3-Column [NavigationSplitView](https://developer.apple.com/documentation/SwiftUI/NavigationSplitView).

## 1. Sidebar

 Sidebar contains value-based navigation links to multiple different child features. In this example, a global `AppReducer` contains nested `FeatureList` reducers - each with their own optional `FeatureDetails` reducers. This ensures that content & detail views in the NavigationSplitView are persisted across multiple selections, and each section can be understood independently.

<img width="900" alt="sidebar" src="https://github.com/kodydeda4/TCA-NavigationSplitView/assets/45678211/0ff2d9d1-8d13-40d9-abfa-4a667f291804">

```swift
// AppReducer

struct AppReducer: Reducer {
  struct State: Equatable {
    var featureA = FeatureList.State(name: "A")
    var featureB = FeatureList.State(name: "B")
    var featureC = FeatureList.State(name: "C")
    
    @BindingState var sidebarDestinationTag: SidebarDestinationTag? = .featureA
    
    enum SidebarDestinationTag: String, Equatable, CaseIterable {
      case featureA = "Feature A"
      case featureB = "Feature B"
      case featureC = "Feature C"
    }
  }
  
  enum Action: BindableAction, Equatable {
    case featureA(FeatureList.Action)
    case featureB(FeatureList.Action)
    case featureC(FeatureList.Action)
    case binding(BindingAction<State>)
  }
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Scope(state: \.featureA, action: /Action.featureA, child: FeatureList.init)
    Scope(state: \.featureB, action: /Action.featureB, child: FeatureList.init)
    Scope(state: \.featureC, action: /Action.featureC, child: FeatureList.init)
  }
}

struct AppView: View {
  let store: StoreOf<AppReducer>
  
  var body: some View {
    NavigationSplitView(
      columnVisibility: .constant(.all),
      sidebar: {
        WithViewStore(store, observe: \.sidebarDestinationTag) { viewStore in
          List(selection: viewStore.binding(get: { $0 }, send: { .binding(.set(\.$sidebarDestinationTag, $0)) })) {
            ForEach(AppReducer.State.SidebarDestinationTag.allCases, id: \.self) { value in
              NavigationLink(value: value) {
                Text(value.rawValue.capitalized)
              }
            }
          }
          .navigationTitle("Sidebar")
        }
      },
      content: {
        WithViewStore(store, observe: \.sidebarDestinationTag) { viewStore in
          switch viewStore.state {
          case .featureA: FeatureListView(store: store.scope(state: \.featureA, action: { .featureA($0) }))
          case .featureB: FeatureListView(store: store.scope(state: \.featureB, action: { .featureB($0) }))
          case .featureC: FeatureListView(store: store.scope(state: \.featureC, action: { .featureC($0) }))
          case .none: EmptyView()
          }
        }
      },
      detail: {
        WithViewStore(store, observe: \.sidebarDestinationTag) { viewStore in
          switch viewStore.state {
          case .featureA: FeatureListDetailsView(store: store.scope(state: \.featureA, action: { .featureA($0) }))
          case .featureB: FeatureListDetailsView(store: store.scope(state: \.featureB, action: { .featureB($0) }))
          case .featureC: FeatureListDetailsView(store: store.scope(state: \.featureC, action: { .featureC($0) }))
          case .none: EmptyView()
          }
        }
      }
    )
  }
}
```

## 2. Content

Content views contain value-based navigation links to `detail` views, as well their own sheets, alerts, confirmationDialogs, etc. Separating the presentation logic for detail and destination states allows the content view to display alerts without losing the detail selection.

<img width="900" alt="content" src="https://github.com/kodydeda4/TCA-NavigationSplitView/assets/45678211/f9663d20-5b16-45fe-94d3-4da3802a65a8">

```swift
// FeatureList

struct FeatureList: Reducer {
  struct State: Equatable {
    let name: String
    var models = IdentifiedArrayOf<Client.Model>()
    @PresentationState var details: FeatureDetails.State?
    @PresentationState var destination: Destination.State?
  }
  
  enum Action: Equatable {
    case task
    case setModels([Client.Model])
    case showDetails(for: Client.Model.ID?)
    case delete(model: Client.Model.ID)
    case newFeatureButtonTapped
    case details(PresentationAction<FeatureDetails.Action>)
    case destination(PresentationAction<Destination.Action>)
  }
  
  @Dependency(\.client) var client
  
  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
        
      case .task:
        return .run { send in
          for await value in await self.client.models() {
            await send(.setModels(value))
          }
        }
        
      case let .setModels(value):
        state.models = .init(uniqueElements: value)
        return .none
        
      case let .delete(model: id):
        return .run { send in
          await self.client.delete(id)
        }
        
      case let .showDetails(for: modelID):
        state.details = modelID.flatMap({ state.models[id: $0] }).flatMap({ FeatureDetails.State(parentName: state.name, model: $0) })
        return .none
        
      case .newFeatureButtonTapped:
        state.destination = .newFeature()
        return .none
        
      case .details:
        return .none
        
      case .destination:
        return .none
      }
    }
    .ifLet(\.$details, action: /Action.details, destination: FeatureDetails.init)
    .ifLet(\.$destination, action: /Action.destination, destination: Destination.init)
  }
  
  struct Destination: Reducer {
    enum State: Equatable {
      case newFeature(NewFeature.State = .init())
    }
    enum Action: Equatable {
      case newFeature(NewFeature.Action)
    }
    var body: some ReducerOf<Self> {
      Scope(state: /State.newFeature, action: /Action.newFeature, child: NewFeature.init)
    }
  }
}

struct FeatureListView: View {
  let store: StoreOf<FeatureList>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      List(selection: viewStore.binding(get: { $0.details?.id }, send: { .showDetails(for: $0) } )) {
        ForEach(viewStore.models) { model in
          NavigationLink(value: model.id) {
            Text(model.name)
          }
          .swipeActions {
            Button("Delete") {
              viewStore.send(.delete(model: model.id))
            }
            .tint(.red)
          }
        }
      }
      .navigationTitle("Content")
      .task { await viewStore.send(.task).finish() }
      .sheet(
        store: store.scope(state: \.$destination, action: FeatureList.Action.destination),
        state: /FeatureList.Destination.State.newFeature,
        action: FeatureList.Destination.Action.newFeature,
        content: NewFeatureSheet.init(store:)
      )
      .toolbar {
        Button(action: { viewStore.send(.newFeatureButtonTapped) }) {
          Image(systemName: "plus")
        }
      }
    }
  }
}

struct FeatureListDetailsView: View {
  let store: StoreOf<FeatureList>
  
  var body: some View {
    IfLetStore(
      store.scope(state: \.$details, action: FeatureList.Action.details),
      then: FeatureDetailsView.init(store:)
    )
  }
}

```

## 3. Detail

Detail views are modeled as optional presentation states for list features. This allows their logic to be understood in isolation.

<img width="900" alt="detail" src="https://github.com/kodydeda4/TCA-NavigationSplitView/assets/45678211/15b56498-19c3-47b3-b03a-55a0b32c2fe6">

```swift
// FeatureDetails

struct FeatureDetails: Reducer {
  struct State: Identifiable, Equatable {
    var id: Client.Model.ID { model.id }
    let parentName: String
    let model: Client.Model
  }

  enum Action: Equatable {
    case none
  }
  var body: some ReducerOf<Self> {
    Reduce { state, action in 
    switch action {
      case .none:
        return .none
      }
    }
  }
}

struct FeatureDetailsView: View {
  let store: StoreOf<FeatureDetails>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      VStack {
        Text("\(viewStore.model.name)")
          .font(.title)
        Text("Feature - \(viewStore.parentName)")
          .foregroundStyle(.secondary)
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .navigationTitle("Detail")
    }
  }
}
```

## Final Thoughts

Please check out`Main.swift`. Suggestions/improvements would be great. thx.
