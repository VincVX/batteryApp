import SwiftUI

struct BatteryDetailsView: View {
    @StateObject private var batteryState = BatteryState.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Battery Icon and Main Info
            HStack(spacing: 15) {
                Text(batteryState.isCharging ? "⚡️" : "🔋")
                    .font(.system(size: 32))
                
                VStack(alignment: .leading) {
                    Text("\(batteryState.percentage)%")
                        .font(.system(size: 24, weight: .medium))
                    Text(statusText)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 8)
            
            Divider()
            
            // Detailed Info
            InfoRow(label: "Power Source", value: batteryState.isPluggedIn ? "Power Adapter" : "Battery")
            InfoRow(label: "Battery Health", value: batteryState.health)
            
            if let time = batteryState.timeRemaining {
                InfoRow(label: "Time Remaining", value: batteryState.formatTime(time))
            }
            
            if let timeToFull = batteryState.timeToFull {
                InfoRow(label: "Time to Full", value: batteryState.formatTime(timeToFull))
            }
            
            Divider()
            
            // Battery Usage Tips
            Text("Battery Tips")
                .font(.headline)
                .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("• Reduce screen brightness")
                Text("• Turn off keyboard backlight when not needed")
                Text("• Close unused applications")
            }
            .font(.system(size: 12))
            .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
        .frame(width: 280)
    }
    
    private var statusText: String {
        if batteryState.isCharging {
            return "Charging"
        } else if batteryState.isPluggedIn {
            return "Connected to Power"
        } else {
            return "On Battery"
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
        }
    }
}
