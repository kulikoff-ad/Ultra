import SwiftUI

@main
struct UltraToolsApp: App {
    @StateObject private var island = IslandManager()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(island)
        }
    }
}

/// Корневой экран: вкладки + плавающий «остров» поверх интерфейса.
struct RootView: View {
    @EnvironmentObject private var island: IslandManager

    var body: some View {
        ZStack(alignment: .top) {
            TabView {
                HomeView()
                    .tabItem { Label("Главная", systemImage: "house.fill") }
                CertificatesView()
                    .tabItem { Label("Сертификаты", systemImage: "checkmark.seal.fill") }
                HiddenFeaturesView()
                    .tabItem { Label("Секреты", systemImage: "eye.slash.fill") }
                DynamicIslandView()
                    .tabItem { Label("Остров", systemImage: "circle.dotted") }
            }
            IslandOverlay()
        }
        .preferredColorScheme(nil)
    }
}
