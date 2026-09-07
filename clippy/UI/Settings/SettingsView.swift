import SwiftUI

// MARK: - Settings Tab Identifier

enum SettingsTab: Hashable {
    case general
    case collections
    case gemini
    case privacy
}

// MARK: - Root SwiftUI view hosting the settings tabs

struct SettingsView: View {
    @State var selectedTab: SettingsTab = .general

    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }
                .tag(SettingsTab.general)

            CollectionsSettings()
                .tabItem { Label("Collections", systemImage: "square.stack") }
                .tag(SettingsTab.collections)

            GeminiSettingsView()
                .tabItem { Label("Gemini AI", systemImage: "sparkles") }
                .tag(SettingsTab.gemini)

            PrivacySettingsView()
                .tabItem { Label("Privacy", systemImage: "hand.raised") }
                .tag(SettingsTab.privacy)
        }
        .frame(width: 550, height: 500)
    }
}
