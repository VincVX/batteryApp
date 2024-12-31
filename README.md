# batteryApp for macOS

A sleek and informative battery status indicator that lives in your macOS menu bar. Get detailed battery information with a beautiful interface and fun animations.

## Features

- 🔋 Real-time battery percentage and status
- ⚡️ Charging status and time remaining
- 🎨 Customizable status bar icons
- ✨ Fun particle animations (Option-click to trigger)
- 🔍 Detailed battery information including [STILL UNFINISHED]:
  - Power source status
  - Battery health
  - Time remaining/Time to full charge

## Screenshots

[Add screenshots here]

## Requirements

- macOS 11.0 or later
- Xcode 13.0 or later (for building from source)

## Installation

### Build from Source
1. Clone the repository:
2. Open the project in Xcode
3. Build the project:
   - Select "Any Mac" as your build target
   - Go to Product > Archive
   - Click "Distribute App"
   - Choose "Copy App"
   - Select a location to save the app

4. Move the exported .app file to your Applications folder

## Usage

- Click the menu bar icon to view detailed battery information
- Option-click the icon to trigger a fun particle animation
- Select different icons from the "Select Icon" menu
- The app automatically starts when you log in

## Privacy & Permissions

The app only requires basic system access to read battery information. It operates within the macOS app sandbox for security.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.


- Built with SwiftUI and AppKit
- Uses IOKit for battery information
