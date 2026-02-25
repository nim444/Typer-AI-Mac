import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    static weak var shared: AppDelegate?

    private var statusItem: NSStatusItem?
    private var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self
        setupMenuBar()
    }

    // MARK: - Menu Bar Setup

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem?.button {
            if let icon = NSImage(named: "typer_icon") {
                // Resize icon to fit the menu bar properly (16x16 is standard for menu bar icons)
                icon.size = NSSize(width: 18, height: 18)
                icon.isTemplate = true
                button.image = icon
            }
            button.action = #selector(handleStatusBarClick)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
            button.target = self
        }

        // Build the popover
        let popover = NSPopover()
        popover.behavior = .transient
        popover.animates = true
        self.popover = popover
        updatePopoverContent()
    }

    private func updatePopoverContent() {
        let view = PopupView(onClose: { [weak self] in
            self?.closePopover()
        })
        popover?.contentViewController = NSHostingController(rootView: view)
        popover?.contentSize = NSSize(width: 420, height: 280)
    }

    // MARK: - Click Handling

    @objc private func handleStatusBarClick(_ sender: NSStatusBarButton) {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showContextMenu()
        } else {
            togglePopover()
        }
    }

    @objc private func togglePopover() {
        guard let button = statusItem?.button else { return }

        if popover?.isShown == true {
            closePopover()
        } else {
            updatePopoverContent()
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover?.contentViewController?.view.window?.makeKey()
            NSApp.activate(ignoringOtherApps: true)
        }
    }

    private func closePopover() {
        popover?.performClose(nil)
    }

    // MARK: - Context Menu (right-click)

    private func showContextMenu() {
        let menu = NSMenu()

        let openItem = NSMenuItem(title: "Open Typer", action: #selector(togglePopover), keyEquivalent: "")
        menu.addItem(openItem)

        menu.addItem(.separator())

        // Provider submenu
        let providerItem = NSMenuItem(title: "Provider", action: nil, keyEquivalent: "")
        let providerMenu = NSMenu()

        let grokItem = NSMenuItem(title: "Grok (xAI)", action: #selector(switchToGrok), keyEquivalent: "")
        grokItem.state = SettingsManager.shared.defaultProvider == "grok" ? .on : .off
        grokItem.target = self

        let geminiItem = NSMenuItem(title: "Gemini (Google)", action: #selector(switchToGemini), keyEquivalent: "")
        geminiItem.state = SettingsManager.shared.defaultProvider == "gemini" ? .on : .off
        geminiItem.target = self

        providerMenu.addItem(grokItem)
        providerMenu.addItem(geminiItem)
        providerItem.submenu = providerMenu
        menu.addItem(providerItem)

        menu.addItem(.separator())

        let settingsItem = NSMenuItem(title: "Settings…", action: #selector(openSettingsWindow), keyEquivalent: ",")
        settingsItem.target = self
        menu.addItem(settingsItem)

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(title: "Quit Typer", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        // Show menu from the button
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }

    // MARK: - Actions

    @objc private func switchToGrok() {
        SettingsManager.shared.defaultProvider = "grok"
        SettingsManager.shared.save()
    }

    @objc private func switchToGemini() {
        SettingsManager.shared.defaultProvider = "gemini"
        SettingsManager.shared.save()
    }

    @objc func openSettingsWindow() {
        closePopover()
        NSApp.activate(ignoringOtherApps: true)
        // Use the standard settings action that SwiftUI's Settings scene responds to
        NSApp.sendAction(Selector(("showSettingsWindow:")), to: nil, from: nil)
    }
}
