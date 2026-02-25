import SwiftUI
import AppKit

struct PopupView: View {
    @ObservedObject private var settings = SettingsManager.shared
    var onClose: (() -> Void)?

    @State private var inputText = ""
    @State private var resultText = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var showResult = false

    var body: some View {
        VStack(spacing: 0) {

            // Header
            HStack(spacing: 8) {
                Image("typer_icon")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)

                Text("Typer")
                    .font(.system(size: 14, weight: .semibold))

                Spacer()

                Picker("", selection: $settings.defaultProvider) {
                    Text("Grok").tag("grok")
                    Text("Gemini").tag("gemini")
                }
                .pickerStyle(.segmented)
                .frame(width: 120)
                .onChange(of: settings.defaultProvider) { _, _ in
                    Task { @MainActor in
                        settings.save()
                    }
                }

                SettingsLink {
                    Image(systemName: "gear")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("Settings")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)

            Divider()

            // Input
            TextEditor(text: $inputText)
                .font(.system(size: 14))
                .frame(minHeight: 90, maxHeight: 120)
                .scrollContentBackground(.hidden)
                .padding(10)
                .overlay(alignment: .topLeading) {
                    if inputText.isEmpty {
                        Text("Type or paste your text here…")
                            .font(.system(size: 14))
                            .foregroundStyle(.tertiary)
                            .padding(.top, 18)
                            .padding(.leading, 14)
                            .allowsHitTesting(false)
                    }
                }

            // Result
            if showResult {
                Divider()

                ScrollView {
                    Text(resultText)
                        .font(.system(size: 14))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .textSelection(.enabled)
                }
                .frame(minHeight: 60, maxHeight: 140)
                .background(Color.green.opacity(0.06))
            }

            Divider()

            // Bottom bar
            HStack(spacing: 8) {
                if !errorMessage.isEmpty {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.caption)
                    Text(errorMessage)
                        .foregroundStyle(.red)
                        .font(.caption)
                        .lineLimit(1)
                }

                Spacer()

                if isLoading {
                    ProgressView()
                        .scaleEffect(0.6)
                        .frame(width: 16, height: 16)
                }

                if showResult {
                    Button("Copy & Close") {
                        copyAndClose()
                    }
                    .keyboardShortcut("c", modifiers: [.command, .shift])

                    Button("Copy") {
                        NSPasteboard.general.clearContents()
                        NSPasteboard.general.setString(resultText, forType: .string)
                    }
                }

                Button(isLoading ? "Fixing…" : "Fix Text") {
                    Task { await fixText() }
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
                .keyboardShortcut(.return, modifiers: [.command])
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
        }
        .frame(width: 420)
    }

    private func fixText() async {
        let trimmed = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        isLoading = true
        errorMessage = ""
        showResult = false

        do {
            let result = try await AIService.fix(text: trimmed, settings: settings)
            resultText = result.trimmingCharacters(in: .whitespacesAndNewlines)
            showResult = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func copyAndClose() {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(resultText, forType: .string)
        onClose?()
    }
}
