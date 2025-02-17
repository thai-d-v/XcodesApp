import AppleAPI
import SwiftUI
import Path

struct AdvancedPreferencePane: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            GroupBox(label: Text("InstallDirectory")) {
                VStack(alignment: .leading) {
                    HStack(alignment: .top, spacing: 5) {
                        Text(appState.installPath).font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                        Button(action: { appState.reveal(path: appState.installPath) }) {
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("RevealInFinder")
                        .fixedSize()
                    }
                    Button("Change") {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = false
                        panel.canChooseDirectories = true
                        panel.canChooseFiles = false
                        panel.canCreateDirectories = true
                        panel.allowedContentTypes = [.folder]
                        panel.directoryURL = URL(fileURLWithPath: appState.installPath)
                        
                        if panel.runModal() == .OK {
                            
                            guard let pathURL = panel.url, let path = Path(url: pathURL) else { return }
                            self.appState.installPath = path.string
                        }
                    }
                    Text("InstallPathDescription")
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .groupBoxStyle(PreferencesGroupBoxStyle())
            
            GroupBox(label: Text("LocalCachePath")) {
                VStack(alignment: .leading) {
                    HStack(alignment: .top, spacing: 5) {
                        Text(appState.localPath).font(.footnote)
                            .fixedSize(horizontal: false, vertical: true)
                            .lineLimit(2)
                        Button(action: { appState.reveal(path: appState.localPath) }) {
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .buttonStyle(PlainButtonStyle())
                        .help("RevealInFinder")
                        .fixedSize()
                    }
                    Button("Change") {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = false
                        panel.canChooseDirectories = true
                        panel.canChooseFiles = false
                        panel.canCreateDirectories = true
                        panel.allowedContentTypes = [.folder]
                        panel.directoryURL = URL(fileURLWithPath: appState.localPath)
                        
                        if panel.runModal() == .OK {
                            
                            guard let pathURL = panel.url, let path = Path(url: pathURL) else { return }
                            self.appState.localPath = path.string
                        }
                    }
                    Text("LocalCachePathDescription")
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .groupBoxStyle(PreferencesGroupBoxStyle())
            
            GroupBox(label: Text("Active/Select")) {
                VStack(alignment: .leading) {
                    Picker("OnSelect", selection: $appState.onSelectActionType) {
                        
                        Text(SelectedActionType.none.description)
                            .tag(SelectedActionType.none)
                        Text(SelectedActionType.rename.description)
                            .tag(SelectedActionType.rename)
                    }
                    .labelsHidden()
                    .pickerStyle(.inline)
                    
                    Text(appState.onSelectActionType.detailedDescription)
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                        .frame(height: 20)
                    
                    Toggle("AutomaticallyCreateSymbolicLink", isOn: $appState.createSymLinkOnSelect)
                        .disabled(appState.createSymLinkOnSelectDisabled)
                    Text("AutomaticallyCreateSymbolicLinkDescription")
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .fixedSize(horizontal: false, vertical: true)
            }
            .groupBoxStyle(PreferencesGroupBoxStyle())
            
            if Hardware.isAppleSilicon() {
                GroupBox(label: Text("Apple Silicon")) {
                    Toggle("ShowOpenInRosetta", isOn: $appState.showOpenInRosettaOption)
                        .disabled(appState.createSymLinkOnSelectDisabled)
                    Text("ShowOpenInRosettaDescription")
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .groupBoxStyle(PreferencesGroupBoxStyle())
            }
            
            GroupBox(label: Text("PrivilegedHelper")) {
                VStack(alignment: .leading, spacing: 8) {
                    switch appState.helperInstallState {
                    case .unknown:
                        ProgressView()
                            .scaleEffect(0.5, anchor: .center)
                    case .installed:
                        Text("HelperInstalled")
                    case .notInstalled:
                        HStack {
                            Text("HelperNotInstalled")
                            Button("InstallHelper") {
                                appState.installHelperIfNecessary()
                            }
                        }
                    }
                    
                    Text("PrivilegedHelperDescription")
                        .font(.footnote)
                        .fixedSize(horizontal: false, vertical: true)
                    
                    Spacer()
                }
            }
            .groupBoxStyle(PreferencesGroupBoxStyle())
        }
    }
}

struct AdvancedPreferencePane_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AdvancedPreferencePane()
                .environmentObject(AppState())
                .frame(maxWidth: 500)
        }
        .frame(width: 500, height: 700, alignment: .center)
    }
}

// A group style for the preferences
struct PreferencesGroupBoxStyle: GroupBoxStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .top, spacing: 20) {
            HStack {
                Spacer()
                configuration.label
            }
            .frame(width: 120)
            
            VStack(alignment: .leading) {
                configuration.content
            }
        }
    }
}
