[![Build macOS App](https://github.com/nim444/Typer-AI-Mac/actions/workflows/build.yml/badge.svg)](https://github.com/nim444/Typer-AI-Mac/actions/workflows/build.yml)
____
<br>


![Banner](assets/banner.png)

![Swift](https://img.shields.io/badge/swift-%23FA7343.svg?style=for-the-badge&logo=swift&logoColor=white)
![macOS](https://img.shields.io/badge/mac%20os-000000?style=for-the-badge&logo=macos&logoColor=F0F0F0)

An AI-powered macOS writing copilot that fixes grammar and adjusts tone — accessible instantly from your menu bar, from anywhere on your Mac.

You're in any app, you have a messy draft. Click the **Typer** icon in your menu bar, paste or type your text, and get a clean rewrite — then tap **Copy & Close** to paste it wherever you were. No switching apps. Just a floating popup over your current screen.




---

### License

**PolyForm Noncommercial License 1.0.0**

This software is licensed for non-commercial use only. You may use this project for personal, academic, and non-profit purposes. **Commercial use, including but not limited to selling this software or using it as part of a paid service, is strictly prohibited.**

See the [LICENSE](LICENSE) file for the full legal text.

___

<br>
<details>
  <summary>1. Features</summary>

- **Menu Bar Access** — instant one-click access to the AI from anywhere on macOS
- **Multi-Provider AI Options** — seamlessly pick between Google Gemini (2.5 & 2.0) and xAI Grok (4.1 & 3 Mini)
- **Quick Provider Switch** — right-click the menu bar icon to toggle between Gemini and Grok on the fly
- **Tabbed Settings** — clean settings window with AI keys, custom prompt, and appearance tabs
- **Customizable Pre-prompt** — write your own base instructions (e.g., "Rewrite to fix grammar and improve clarity")
- **Copy & Close** — automatically copies the polished text to your clipboard and dismisses the popup
- **Hide API Keys** — secure password-style visibility toggles for your saved API keys
- **Launch at Login** — optional auto-start so Typer is always in your menu bar
- **Persistent Secure Storage** — API keys stored in macOS Keychain, preferences in UserDefaults
</details>

<details>
  <summary>2. Setup & Installation</summary>

#### Get an API Key (Gemini or Grok)
1. **Gemini:** Go to [aistudio.google.com/apikey](https://aistudio.google.com/apikey) to generate a free key.
2. **Grok:** Go to [console.x.ai](https://console.x.ai/) to generate a Grok API key.

#### Install the App
1. Go to the [Actions tab](../../actions) on GitHub.
2. Open the latest successful **Build macOS App** run.
3. Download the `Typer-Mac` artifact and unzip it.
4. Move `Typer.app` to your `/Applications` folder.
5. Launch it — the Typer icon will appear in your menu bar.

> **Note:** Because the app is not notarized, macOS may block it on first launch. Right-click `Typer.app` → **Open** → **Open** to bypass Gatekeeper.
</details>

<details>
  <summary>3. How To Use</summary>

1. **Launch Typer** — the icon appears in your menu bar.
2. **Right-click** the icon → **Settings** to configure your API keys, model, and prompt.
3. **Left-click** the icon to open the popup from any app.
4. **Paste or type** your draft text into the input field.
5. Tap **Fix Text** (or `⌘Return`).
6. Review the result, then tap **Copy & Close** (`⌘⇧C`) to paste into any app.

To **switch providers** on the fly: right-click the menu bar icon → **Provider** → select Grok or Gemini.
</details>

<details>
  <summary>4. API Tier Limits (Reference)</summary>

| Provider | Model | Typical Free Tier |
|---|---|---|
| Google (Gemini) | `gemini-2.5-flash` | 15 RPM / 1M TPM / 1,500 RPD |
| xAI (Grok) | `grok-4-1-fast-non-reasoning` | Approx $5.00/1M tokens (depends on active tier) |

*Always verify up-to-date quotas with your respective provider console.*
</details>

<details>
  <summary>5. Tech Stack & Project Structure</summary>

| Component | Technology |
|---|---|
| Language | Swift 5.9 |
| UI | SwiftUI + AppKit |
| AI | Google Gemini & xAI Grok (via URLSession HTTP) |
| Storage | macOS Keychain (API keys) + UserDefaults (preferences) |
| Entry point | NSStatusItem (menu bar icon) |
| Build | Xcode / xcodegen 2.x |
| CI | GitHub Actions → macOS app artifact |

```text
Typer-AI-Mac/
├── TyperAI/
│   ├── TyperAIApp.swift           # App entry point, Settings scene
│   ├── AppDelegate.swift          # Menu bar icon, popover, context menu
│   ├── LoginItemManager.swift     # Launch at login (SMAppService)
│   ├── Services/
│   │   ├── AIService.swift        # Network dispatcher for Grok and Gemini
│   │   └── SettingsManager.swift  # Keychain + UserDefaults persistence
│   ├── Views/
│   │   ├── PopupView.swift        # Main popup: input, fix, copy
│   │   └── SettingsView.swift     # Tabbed settings: AI, Prompt, Appearance
│   └── Assets.xcassets/           # App icon, menu bar icon, logos
├── assets/                        # README assets (banner, icon)
├── .github/workflows/
│   └── build.yml                  # CI: builds macOS app artifact
└── project.yml                    # xcodegen project spec
```
</details>
