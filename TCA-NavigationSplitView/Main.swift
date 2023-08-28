import SwiftUI
import ComposableArchitecture
import Dependencies

@main
struct Main: App {
  var body: some Scene {
    WindowGroup {
      AppView(store: Store(
        initialState: AppReducer.State(),
        reducer: AppReducer.init
      ))
    }
  }
}

// MARK: - AppReducer

struct AppReducer: Reducer {
  struct State: Equatable {
    var featureA = FeatureList.State(name: "A")
    var featureB = FeatureList.State(name: "B")
    var featureC = FeatureList.State(name: "C")
    
    @BindingState var destinationTag: DestinationTag? = .featureA
    
    enum DestinationTag: String, Equatable, CaseIterable {
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
        WithViewStore(store, observe: \.destinationTag) { viewStore in
          List(selection: viewStore.binding(get: { $0 }, send: { .binding(.set(\.$destinationTag, $0)) })) {
            ForEach(AppReducer.State.DestinationTag.allCases, id: \.self) { value in
              NavigationLink(value: value) {
                Text(value.rawValue.capitalized)
              }
            }
          }
          .navigationTitle("Sidebar")
        }
      },
      content: {
        WithViewStore(store, observe: \.destinationTag) { viewStore in
          switch viewStore.state {
          case .featureA: FeatureListView(store: store.scope(state: \.featureA, action: { .featureA($0) }))
          case .featureB: FeatureListView(store: store.scope(state: \.featureB, action: { .featureB($0) }))
          case .featureC: FeatureListView(store: store.scope(state: \.featureC, action: { .featureC($0) }))
          case .none: EmptyView()
          }
        }
      },
      detail: {
        WithViewStore(store, observe: \.destinationTag) { viewStore in
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

// MARK: - FeatureList

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

// MARK: - FeatureDetails

struct FeatureDetails: Reducer {
  struct State: Identifiable, Equatable {
    var id: Client.Model.ID { model.id }
    let parentName: String
    let model: Client.Model
  }
  enum Action: Equatable {
    //...
  }
  var body: some ReducerOf<Self> {
    EmptyReducer()
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

// MARK: - NewFeature

struct NewFeature: Reducer {
  struct State: Equatable {
    @BindingState var name = String()
    var model: Client.Model? { .init(id: .init(), name: name) }
  }
  
  enum Action: BindableAction, Equatable {
    case cancelButtonTapped
    case saveButtonTapped
    case binding(BindingAction<State>)
  }
  
  @Dependency(\.client) var client
  @Dependency(\.dismiss) var dismiss
  
  var body: some ReducerOf<Self> {
    BindingReducer()
    Reduce { state, action in
      switch action {
        
      case .cancelButtonTapped:
        return .run { _ in await self.dismiss() }
        
      case .saveButtonTapped:
        guard let model = state.model else { return .none }
        return .run { send in
          await client.save(model)
          await self.dismiss()
        }
        
      case .binding:
        return .none
        
      }
    }
  }
}

struct NewFeatureSheet: View {
  let store: StoreOf<NewFeature>
  
  var body: some View {
    WithViewStore(store, observe: { $0 }) { viewStore in
      NavigationStack {
        List {
          TextField("Name", text: viewStore.$name)
        }
        .navigationTitle("New Feature")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
              viewStore.send(.cancelButtonTapped)
            }
          }
          ToolbarItem(placement: .primaryAction) {
            Button("Save") {
              viewStore.send(.saveButtonTapped)
            }
            .disabled(viewStore.name.isEmpty)
          }
        }
      }
    }
  }
}

struct Client: DependencyKey {
  var models: @Sendable () async -> AsyncStream<[Model]>
  var save: @Sendable (Model) async -> Void
  var delete: @Sendable (Model.ID) async -> Void
  
  struct Model: Identifiable, Equatable {
    let id: UUID
    let name: String
  }
}

extension DependencyValues {
  var client: Client {
    get { self[Client.self] }
    set { self[Client.self] = newValue }
  }
}

extension Client {
  static var liveValue: Self {
    final actor ActorState {
      @Published var models = IdentifiedArrayOf<Model>(uniqueElements: [
        .init(id: .init(), name: "Model A"),
        .init(id: .init(), name: "Model B"),
        .init(id: .init(), name: "Model C"),
      ])
      func save(_ model: Model) {
        self.models.updateOrAppend(model)
      }
      func delete(_ modelID: Model.ID) {
        self.models.remove(id: modelID)
      }
    }
    let actor = ActorState()
    return Self(
      models: {
        AsyncStream { continuation in
          let task = Task {
            while !Task.isCancelled {
              for await value in await actor.$models.values {
                continuation.yield(value.elements)
              }
            }
          }
          continuation.onTermination = { _ in task.cancel() }
        }
      },
      save: { await actor.save($0) },
      delete: { await actor.delete($0) }
    )
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
      .previewInterfaceOrientation(.landscapeLeft)
  }
}
