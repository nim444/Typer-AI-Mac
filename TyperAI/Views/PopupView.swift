import SwiftUI
import AppKit

struct PopupView: View {
    @ObservedObject private var settings = SettingsManager.shared

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

                Button {
                    AppDelegate.shared?.openSettingsWindow()
                } label: {
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
                .font(.system(size: CGFloat(settings.fontSize)))
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
                    Text(buildDiff(original: inputText, result: resultText))
                        .font(.system(size: CGFloat(settings.fontSize)))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(10)
                        .textSelection(.enabled)
                }
                .frame(minHeight: 60, maxHeight: 140)
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
            recordStats(input: trimmed, result: resultText)
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    private func recordStats(input: String, result: String) {
        let origWords = input.components(separatedBy: " ")
        let resultWords = result.components(separatedBy: " ")
        let common = lcs(origWords, resultWords)
        let changed = resultWords.count - common.count
        settings.totalFixes += 1
        settings.charactersFixed += input.count
        settings.wordsChanged += max(0, changed)
        settings.save()
    }

    private func buildDiff(original: String, result: String) -> AttributedString {
        let origWords = original.components(separatedBy: " ")
        let resultWords = result.components(separatedBy: " ")
        let common = lcs(origWords, resultWords)
        var commonIdx = 0
        var attrStr = AttributedString()
        for (i, word) in resultWords.enumerated() {
            if i > 0 { attrStr.append(AttributedString(" ")) }
            var part = AttributedString(word)
            if commonIdx < common.count && common[commonIdx] == word {
                commonIdx += 1
            } else {
                part.backgroundColor = Color.green.opacity(0.4)
            }
            attrStr.append(part)
        }
        return attrStr
    }

    private func lcs(_ a: [String], _ b: [String]) -> [String] {
        let m = a.count, n = b.count
        guard m > 0, n > 0 else { return [] }
        var dp = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)
        for i in 1...m {
            for j in 1...n {
                dp[i][j] = a[i-1] == b[j-1] ? dp[i-1][j-1] + 1 : max(dp[i-1][j], dp[i][j-1])
            }
        }
        var result: [String] = []
        var i = m, j = n
        while i > 0 && j > 0 {
            if a[i-1] == b[j-1] {
                result.append(a[i-1]); i -= 1; j -= 1
            } else if dp[i-1][j] >= dp[i][j-1] {
                i -= 1
            } else {
                j -= 1
            }
        }
        return result.reversed()
    }
}
