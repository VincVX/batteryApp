import Foundation
import Combine
import IOKit.ps

class BatteryState: ObservableObject {
    @Published private(set) var isPluggedIn = false
    @Published private(set) var percentage = 0
    @Published private(set) var timeRemaining: Int?
    @Published private(set) var isCharging = false
    @Published private(set) var health = "Good"
    @Published private(set) var timeToFull: Int?
    
    private var powerSourceNotification: CFRunLoopSource?
    
    static let shared = BatteryState()
    
    private init() {
        setupPowerSourceMonitoring()
        updateState()
    }
    
    private func setupPowerSourceMonitoring() {
        let callback: IOPowerSourceCallbackType = { _ in
            BatteryState.shared.updateState()
            return Void()
        }
        
        powerSourceNotification = IOPSNotificationCreateRunLoopSource(callback, nil).takeRetainedValue()
        
        if let runLoopSource = powerSourceNotification {
            CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .defaultMode)
        }
    }
    
    func updateState() {
        let powerSource = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let powerSourcesList = IOPSCopyPowerSourcesList(powerSource).takeRetainedValue() as Array
        
        guard let source = powerSourcesList.first,
              let desc = IOPSGetPowerSourceDescription(powerSource, source).takeUnretainedValue() as? [String: Any] else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.isPluggedIn = desc[kIOPSPowerSourceStateKey] as? String == kIOPSACPowerValue
            self.percentage = desc[kIOPSCurrentCapacityKey] as? Int ?? 0
            self.isCharging = desc[kIOPSIsChargingKey] as? Bool ?? false
            self.health = desc[kIOPSBatteryHealthKey] as? String ?? "Good"
            
            if self.isCharging {
                let rawTimeToFull = desc[kIOPSTimeToFullChargeKey] as? Int ?? -1
                self.timeToFull = rawTimeToFull > 0 ? rawTimeToFull : nil
                self.timeRemaining = nil
            } else if !self.isPluggedIn {
                let rawTimeRemaining = desc[kIOPSTimeToEmptyKey] as? Int ?? -1
                self.timeRemaining = rawTimeRemaining > 0 ? rawTimeRemaining : nil
                self.timeToFull = nil
            } else {
                self.timeRemaining = nil
                self.timeToFull = nil
            }
        }
    }
    
    deinit {
        if let runLoopSource = powerSourceNotification {
            CFRunLoopRemoveSource(CFRunLoopGetCurrent(), runLoopSource, .defaultMode)
        }
    }
    
    func formatTime(_ minutes: Int) -> String {
        let hours = minutes / 60
        let mins = minutes % 60
        return "\(hours)h \(mins)m"
    }
}

extension Notification.Name {
    static let batteryStateDidChange = Notification.Name("BatteryStateDidChange")
} 