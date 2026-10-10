import SwiftUI

enum AppScreen {
    case splash, login, home
}

struct RootView: View {
    @State private var screen: AppScreen = .splash
    @StateObject private var store = AppStore()

    var body: some View {
        ZStack {
            switch screen {
            case .splash:
                SplashView()
                    .transition(.opacity)
            case .login:
                LoginView {
                    withAnimation(.easeInOut(duration: 0.4)) {
                        screen = .home
                    }
                }
                .transition(.opacity)
            case .home:
                HomeView(onOpenCart: {})
                    .transition(.opacity)
            }
        }
        .environmentObject(store)
        .task {
            try? await Task.sleep(nanoseconds: 3_200_000_000)
            await MainActor.run {
                withAnimation(.easeInOut(duration: 0.5)) {
                    screen = .login
                }
            }
        }
    }
}
