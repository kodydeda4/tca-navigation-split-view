import SwiftUI
import ComposableArchitecture

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
