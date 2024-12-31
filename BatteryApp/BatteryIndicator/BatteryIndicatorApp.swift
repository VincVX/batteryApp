import SwiftUI

@main
struct BatteryIndicatorApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        Settings {
            EmptyView()
        }
        .commands {
            // Remove all default menu items
            CommandGroup(replacing: CommandGroupPlacement.appInfo) { }
            CommandGroup(replacing: CommandGroupPlacement.newItem) { }
            CommandGroup(replacing: CommandGroupPlacement.windowList) { }
            CommandGroup(replacing: CommandGroupPlacement.systemServices) { }
        }
    }
} 