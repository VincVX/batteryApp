import SwiftUI
import IOKit.ps
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    private var animationPanel: NSPanel?
    private var isAnimating = false
    private var menu: NSMenu?
    private let defaultEmojis = ["⚡️", "🌟", "✨", "💫", "⭐️", "🌠", "🎇", "🎆"]
    @AppStorage("selectedEmoji") private var selectedEmoji: String = "⚡️"
    private var powerSourceNotification: CFRunLoopSource?
    private var batteryStateObserver: AnyCancellable?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        setupMenuBar()
        setupAnimationPanel()
        
        // Observe battery state changes
        batteryStateObserver = BatteryState.shared.objectWillChange.sink { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateDisplay()
            }
        }
    }
    
    deinit {
        batteryStateObserver?.cancel()
    }
    
    private func getBatteryInfo() -> String {
        let state = BatteryState.shared
        
        // On battery power
        if !state.isCharging && !state.isPluggedIn {
            if let timeRemaining = state.timeRemaining {
                let hours = timeRemaining / 60
                let minutes = timeRemaining % 60
                return "\(selectedEmoji) \(hours):\(String(format: "%02d", minutes))"
            }
        }
        
        // On power adapter or no time remaining available
        return "\(selectedEmoji) \(state.percentage)%"
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            updateDisplay()
            
            // Create menu
            let menu = NSMenu()
            
            // Create battery details menu item with custom view
            let detailsItem = NSMenuItem()
            let hostingView = NSHostingView(rootView: BatteryDetailsView())
            hostingView.frame = NSRect(x: 0, y: 0, width: 280, height: 280)
            detailsItem.view = hostingView
            
            menu.addItem(detailsItem)
            
            menu.addItem(NSMenuItem.separator())
            
            // Add emoji selector submenu
            let emojiMenu = NSMenu()
            for emoji in defaultEmojis {
                let item = NSMenuItem(
                    title: emoji,
                    action: #selector(emojiSelected(_:)),
                    keyEquivalent: ""
                )
                item.target = self
                if emoji == selectedEmoji {
                    item.state = .on
                }
                emojiMenu.addItem(item)
            }
            
            let emojiMenuItem = NSMenuItem(title: "Select Icon", action: nil, keyEquivalent: "")
            emojiMenuItem.submenu = emojiMenu
            menu.addItem(emojiMenuItem)
            
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "Option-click for \(selectedEmoji) animation", action: nil, keyEquivalent: "")
            menu.addItem(NSMenuItem.separator())
            menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
            
            // Store menu reference
            self.menu = menu
            
            // Add click handler
            button.target = self
            button.action = #selector(statusBarButtonClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    private func setupAnimationPanel() {
        guard let screen = NSScreen.main else { return }
        
        let panel = NSPanel(
            contentRect: screen.frame,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )
        panel.level = .floating
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.hasShadow = false
        panel.ignoresMouseEvents = true
        
        let hostingView = NSHostingView(rootView: 
            FallingEmojisView(emoji: selectedEmoji)
                .frame(width: screen.frame.width, height: screen.frame.height)
        )
        panel.contentView = hostingView
        
        animationPanel = panel
    }
    
    private func updateBatteryDetails() {
        if let button = statusItem?.button {
            button.title = getBatteryInfo()
        }
    }
    
    @objc private func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent
        
        if event?.modifierFlags.contains(.option) == true {
            // Option-click triggers animation
            showAnimation()
        } else {
            // Regular click shows menu
            statusItem?.menu = menu
            statusItem?.button?.performClick(nil)
            statusItem?.menu = nil  // Reset menu after click
        }
    }
    
    private func showAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        
        if let screen = NSScreen.main {
            NotificationCenter.default.post(name: Notification.Name("ResetEmojis"), object: nil)
            animationPanel?.setFrame(screen.frame, display: false)
            animationPanel?.orderFront(nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                self?.animationPanel?.orderOut(nil)
                self?.isAnimating = false
            }
        }
    }
    
    @objc private func emojiSelected(_ sender: NSMenuItem) {
        selectedEmoji = sender.title
        
        // Update checkmarks
        if let emojiMenu = menu?.items
            .first(where: { $0.title == "Select Icon" })?
            .submenu {
            for item in emojiMenu.items {
                item.state = item.title == selectedEmoji ? .on : .off
            }
        }
        
        updateDisplay()
    }
    
    private func updateDisplay() {
        if let button = statusItem?.button {
            button.title = getBatteryInfo()
        }
    }
} 
