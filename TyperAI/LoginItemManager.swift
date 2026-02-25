import Foundation
import ServiceManagement

class LoginItemManager {
    static let shared = LoginItemManager()
    
    private init() {}
    
    /// Check if the app is set to launch at login
    var isEnabled: Bool {
        if #available(macOS 13.0, *) {
            return SMAppService.mainApp.status == .enabled
        } else {
            // For macOS 12 and earlier, check UserDefaults as a fallback
            return UserDefaults.standard.bool(forKey: "launchAtLogin")
        }
    }
    
    /// Enable or disable launch at login
    func setEnabled(_ enabled: Bool) throws {
        if #available(macOS 13.0, *) {
            if enabled {
                if SMAppService.mainApp.status == .enabled {
                    // Already enabled
                    return
                }
                try SMAppService.mainApp.register()
            } else {
                if SMAppService.mainApp.status == .notRegistered {
                    // Already disabled
                    return
                }
                try SMAppService.mainApp.unregister()
            }
        } else {
            // For macOS 12 and earlier, just store the preference
            UserDefaults.standard.set(enabled, forKey: "launchAtLogin")
        }
    }
}
