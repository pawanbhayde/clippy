import SwiftUI

// MARK: - Root SwiftUI view hosting the settings tabs

struct SettingsView: View {
    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem { Label("General", systemImage: "gearshape") }
            CollectionsSettings()
                .tabItem { Label("Collections", systemImage: "square.stack") }
            PrivacySettingsView()
                .tabItem { Label("Privacy", systemImage: "hand.raised") }
        }
        .frame(width: 520, height: 460)
    }
}
