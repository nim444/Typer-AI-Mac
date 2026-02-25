import SwiftUI

struct SettingsView: View {
    @ObservedObject private var settings = SettingsManager.shared
    @State private var showGrokKey = false
    @State private var showGeminiKey = false
    @State private var launchAtLogin = LoginItemManager.shared.isEnabled
    @State private var showLoginItemError = false
    @State private var loginItemErrorMessage = ""

    var body: some View {
        TabView {
            // AI Providers
            Form {
                Section {
                    Picker("Default Provider", selection: $settings.defaultProvider) {
                        Text("Grok (xAI)").tag("grok")
                        Text("Gemini (Google)").tag("gemini")
                    }
                    .pickerStyle(.radioGroup)
                } header: {
                    Text("Default Provider")
                }

                Divider().padding(.vertical, 4)

                Section {
                    HStack {
                        Group {
                            if showGrokKey {
                                TextField("Grok API Key", text: $settings.grokApiKey)
                            } else {
                                SecureField("Grok API Key", text: $settings.grokApiKey)
                            }
                        }
                        .textFieldStyle(.roundedBorder)

                        Button(showGrokKey ? "Hide" : "Show") {
                            showGrokKey.toggle()
                        }
                        .frame(width: 44)
                    }

                    Picker("Model", selection: $settings.grokModel) {
                        ForEach(settings.grokModels, id: \.self) { Text($0).tag($0) }
                    }
                } header: {
                    Text("Grok (xAI)")
                }

                Divider().padding(.vertical, 4)

                Section {
                    HStack {
                        Group {
                            if showGeminiKey {
                                TextField("Gemini API Key", text: $settings.geminiApiKey)
                            } else {
                                SecureField("Gemini API Key", text: $settings.geminiApiKey)
                            }
                        }
                        .textFieldStyle(.roundedBorder)

                        Button(showGeminiKey ? "Hide" : "Show") {
                            showGeminiKey.toggle()
                        }
                        .frame(width: 44)
                    }

                    Picker("Model", selection: $settings.geminiModel) {
                        ForEach(settings.geminiModels, id: \.self) { Text($0).tag($0) }
                    }
                } header: {
                    Text("Google Gemini")
                }
            }
            .formStyle(.grouped)
            .tabItem { Label("AI", systemImage: "brain") }

            // Prompt
            Form {
                Section {
                    TextEditor(text: $settings.customPrompt)
                        .font(.system(size: 13, design: .monospaced))
                        .frame(minHeight: 120)
                        .scrollContentBackground(.hidden)
                } header: {
                    Text("Custom Prompt")
                } footer: {
                    Text("The AI will use this as its instruction. Your text is appended at the end.")
                        .foregroundStyle(.secondary)
                }
            }
            .formStyle(.grouped)
            .tabItem { Label("Prompt", systemImage: "text.bubble") }

            // Appearance
            Form {
                Section {
                    Toggle("Launch at Login", isOn: $launchAtLogin)
                        .onChange(of: launchAtLogin) { _, newValue in
                            do {
                                try LoginItemManager.shared.setEnabled(newValue)
                            } catch {
                                // Revert the toggle if it fails
                                launchAtLogin = !newValue
                                loginItemErrorMessage = error.localizedDescription
                                showLoginItemError = true
                            }
                        }
                } header: {
                    Text("General")
                }
                
                Divider().padding(.vertical, 4)
                
                Section {
                    Picker("Theme", selection: $settings.theme) {
                        Text("System").tag("system")
                        Text("Light").tag("light")
                        Text("Dark").tag("dark")
                    }
                    .pickerStyle(.radioGroup)
                } header: {
                    Text("Appearance")
                }
            }
            .formStyle(.grouped)
            .tabItem { Label("General", systemImage: "gear") }
            .alert("Login Item Error", isPresented: $showLoginItemError) {
                Button("OK") { showLoginItemError = false }
            } message: {
                Text(loginItemErrorMessage)
            }
        }
        .padding()
        .frame(width: 480, height: 360)
        .onDisappear {
            Task { @MainActor in
                settings.save()
            }
        }
        .onChange(of: settings.defaultProvider) { _, _ in
            Task { @MainActor in
                settings.save()
            }
        }
        .onChange(of: settings.grokModel) { _, _ in
            Task { @MainActor in
                settings.save()
            }
        }
        .onChange(of: settings.geminiModel) { _, _ in
            Task { @MainActor in
                settings.save()
            }
        }
        .onChange(of: settings.grokApiKey) { _, _ in
            Task { @MainActor in
                settings.save()
            }
        }
        .onChange(of: settings.geminiApiKey) { _, _ in
            Task { @MainActor in
                settings.save()
            }
        }
        .onChange(of: settings.customPrompt) { _, _ in
            Task { @MainActor in
                settings.save()
            }
        }
        .onChange(of: settings.theme) { _, _ in
            Task { @MainActor in
                settings.save()
            }
        }
    }
}
