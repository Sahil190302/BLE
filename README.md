A production-grade BLE device scanner and connector built with Flutter for the Jinn wearable-connectivity assignment. Discovers nearby Bluetooth Low Energy peripherals, connects to a selected device, enumerates its GATT services and characteristics, reads the standard Battery Service, and gracefully handles every realistic failure mode — permission denial, Bluetooth toggled off, connection loss, and peripheral withdrawal.

Target platform: Android (iOS configuration intentionally omitted; see Platform Scope).

Table of Contents
Features

Screenshots / UI States

Architecture — MVC

Project Structure

Why This Approach

Edge Cases Handled

Permissions

Dependencies

How to Run

Testing Checklist

Platform Scope

Debug Logging

Known Limitations

License

Features
Scan & Discover
Live BLE scan using flutter_blue_plus with a 15-second timeout window

Device list sorted by RSSI (strongest signal first), updating in real time as new advertisements arrive

Visual RSSI bar (green / orange / red thresholds) with raw dBm value

Scanning-in-progress indicator at the top of the list

Auto-refresh of discovered devices as broadcasts come in

Connect & Inspect
One-tap connect from the device list, with automatic navigation to the detail screen on success

Full GATT service and characteristic enumeration after connection

Per-characteristic property chips (Read / Write / Notify / Indicate)

Readable characteristics expose a one-tap "Read" button that fetches and displays the hex payload inline

Standard Battery Service (180f / 2a19) is read automatically on discovery and rendered as a large percentage card with color-coded threshold (green > 20 %, red ≤ 20 %)

Friendly names for well-known GATT services (1800 Generic Access, 180a Device Information, 180f Battery, 180d Heart Rate, etc.); unknown UUIDs fall back to "Custom Service" while still exposing the raw UUID

Connection Lifecycle
Explicit connection status machine: disconnected → connecting → connected → disconnecting → disconnected

Automatic detection of unexpected disconnection via the plugin's connectionState stream

Full-screen reconnect view with a prominent Reconnect button when the device drops

Manual disconnect from the detail screen's AppBar (returns to the scan list)

Connecting state disables the primary action to prevent double-taps

System-State Awareness
Live Bluetooth adapter state tracking (on / off / unknown)

Amber warning banner with Turn on action when Bluetooth is off — invokes FlutterBluePlus.turnOn() to open the system dialog

Red error banner with Open Settings action when runtime permissions are denied

Scan button visually disabled while Bluetooth is off

Graceful fallback empty states for "no devices found yet" and "Bluetooth off"

UI / UX
Material 3 design with a professional blue seed color (#2563EB)

Gradient hero card on the detail screen showing device name + live connection status badge

Custom card-based device tiles with circular iconography and inline signal meter

Auto-contrast primary buttons (colorScheme.primary / onPrimary) — text and icons flip automatically when the seed color changes

Floating snackbar for transient errors (connection failures) without interrupting the flow

Full-screen error/loading states for service discovery and disconnection
