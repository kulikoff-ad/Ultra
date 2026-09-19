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
                InstallIPAView()
                    .tabItem { Label("Установка", systemImage: "square.and.arrow.down.fill") }
                HiddenFeaturesView()
                    .tabItem { Label("Секреты", systemImage: "eye.slash.fill") }
                JailbreakView()
                    .tabItem { Label("Джейл", systemImage: "lock.open.fill") }
                DynamicIslandView()
                    .tabItem { Label("Остров", systemImage: "circle.dotted") }
            }
            IslandOverlay()
        }
        .preferredColorScheme(nil)
    }
}
