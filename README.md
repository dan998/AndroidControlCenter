# Android Control Center

Android Control Center is a private project for managing authorized Android devices through a Windows desktop application, with planned local and online web dashboards.

## Project Goals

- Manage authorized Android devices through ADB.
- Control device screens using scrcpy.
- Provide Samsung and universal device diagnostics.
- Support USB and wireless debugging.
- Provide secure device registration and authorization.
- Offer local and online web dashboards.
- Support Android companion application integration.

## Current Components

| Component | Status |
|---|---|
| Windows PowerShell dashboard | Existing |
| ADB device detection | Existing |
| scrcpy integration | Existing |
| Samsung USB diagnostics | Existing |
| IMEI format and checksum validator | Existing |
| IMEI reader | Limited by Android permissions |
| Samsung and universal GUI panels | Existing |
| Recovery Center | Existing |
| Termux SSH/SFTP | Incomplete |
| Wireless connection management | Local wireless ADB available; broader management incomplete |
| Device authorization modules | Incomplete |
| Android companion application | Planned |
| Local web dashboard | Created; verification pending |
| Online web dashboard | Planned |

Existing components may require further testing.

## Technology

### Windows application

- Windows 10/11 x64
- Windows PowerShell 5.1
- Windows Forms
- Android Debug Bridge (ADB)
- scrcpy

### Web platform (planned)

- HTML5
- CSS3
- JavaScript
- Node.js LTS
- npm
- Secure REST API
- HTTPS
- Authentication and role-based authorization

### Online services (planned)

- Supabase for authentication and database services.
- Netlify for website hosting.
- Secure communication between the online service and Windows agent.

### Android companion (planned)

- Android Studio
- Kotlin
- Android SDK
- Supported Android APIs

## System Requirements

### Current Windows application

- Windows 10 or Windows 11, 64-bit.
- Windows PowerShell 5.1.
- ADB.
- scrcpy.
- Android device with USB debugging enabled.
- USB cable or supported wireless ADB connection.

### Web development

- Node.js LTS and npm.
- Git.
- Modern web browser.
- Internet connection for online services.

### Android development

- Android Studio.
- Android SDK and platform tools.
- Android Studio bundled Java runtime.
- Android device or emulator for testing.

Gradle can be managed through the Android Gradle Wrapper when the companion project is created.

## Installation

See [Installation Guide](docs/INSTALLATION.md).

## Starting the Windows Application

Open PowerShell:

```powershell
cd C:\Users\User\AndroidControlCenter
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\AndroidControlCenter.ps1
```

The application searches for ADB and scrcpy on PATH or in its expected project-relative locations.

It loads the following GUI integration module:

```text
gui/ManufacturerIntegration.ps1
```

Keep the main application and its GUI modules in their expected relative locations.

## Planned Website Architecture

The intended architecture is:

```text
Browser
   |
   | HTTPS
   v
Online Website / Local Website
   |
   v
Authenticated Backend API
   |
   v
Windows Control Agent
   |
   v
ADB / scrcpy
   |
   v
Authorized Android Device
```

Local mode should support local device operations without requiring an internet connection.

Online mode will use authenticated communication. ADB and device-control ports must never be exposed directly to the public internet.

## Security

- Only manage devices with owner authorization.
- Never publish private SSH keys, passwords or access tokens.
- Keep local configuration and trusted-device records out of Git.
- Require authentication for remote operations.
- Use HTTPS for online communication.
- Validate and authorize every remote command.
- Record security-sensitive actions in audit logs.
- Respect Android permissions and platform restrictions.
- Location tracking must be explicitly authorized and visible.
- Do not bypass Android security restrictions.

IMEI availability depends on Android permissions, device firmware and system privileges. Reading an IMEI is not guaranteed.

## Project Structure

```text
AndroidControlCenter/
├── android/
│   └── remote/
├── config/
├── connection/
│   ├── providers/
│   └── security/
├── devices/
├── docs/
│   └── INSTALLATION.md
├── gui/
├── security/
├── windows/
├── AndroidControlCenter.ps1
├── ACCPatternRecovery.ps1
└── README.md
```

The web directory contains the initial local dashboard and Node.js server. Further development and verification are ongoing.

## Development Roadmap

1. Complete Windows application and module reliability.
2. Establish installation and configuration standards.
3. Build the local web dashboard and API.
4. Connect the dashboard to the Windows control agent.
5. Implement authentication and device authorization.
6. Build the online dashboard and secure communication.
7. Develop the Android companion application.
8. Test security, reliability and recovery procedures.

## Contributing

This is a private project. Changes should be tested independently before integration.

Do not replace existing working modules without reviewing their functionality and preserving backups.

## GLOBAL CONNECTIVITY AND WI-FI FEATURES

The long-term goal is to manage owner-authorized Android devices anywhere in the world using Wi-Fi or mobile data.

### Global device connectivity (planned)

- Connect to authorized devices across different networks and countries.
- Support Wi-Fi and cellular/mobile-data connections.
- Securely register devices and authenticate remote sessions.
- Use encrypted communication and an authenticated remote relay.
- Support VPN connections where appropriate.
- Preserve existing USB and local wireless ADB functionality.
- Never expose ADB or SSH ports directly to the public internet.

Worldwide remote connectivity is not yet implemented. NAT, carrier restrictions, firewalls, internet availability and device permissions must be addressed.

### Android Wi-Fi and network diagnostics (planned)

Where Android permits access, retrieve:

- Connected Wi-Fi network name (SSID).
- Wi-Fi connection status.
- IP address, gateway and DNS information.
- Wi-Fi frequency, link speed and signal strength.
- Mobile network type, operator and signal information.
- Connection history and diagnostic timestamps.

Windows network information must be distinguished from Android phone network information. Restricted information must be reported as unavailable rather than obtained by bypassing Android permissions.

### Automatic Wi-Fi QR scanning (planned)

- Automatically detect Wi-Fi QR codes using a camera.
- Import QR-code images and screenshots.
- Decode the SSID, password and security type when included in the QR code.
- Match decoded network details with the phone's connected Wi-Fi network.
- Display network and connection information.
- Provide an explicit action to reveal a decoded password.
- Report unreadable QR codes or codes without passwords.

Wi-Fi passwords are sensitive. They must not be uploaded to Netlify, Supabase or another remote service. A saved Wi-Fi password cannot be assumed accessible merely because the phone is connected.

### Windows cellular diagnostics (planned)

- Check WWAN AutoConfig service status.
- Detect mobile broadband hardware.
- Identify available cellular interfaces.
- Read SIM and network information exposed by Windows.
- Report unsupported or unavailable hardware and information.

Windows cellular diagnostics are separate from Android phone SIM diagnostics.

### Remote device monitoring (planned)

The Android companion application is intended to provide authorized access to:

- Device model, manufacturer, Android version and build information.
- Battery and charging status.
- Network and connectivity information.
- Device health and diagnostics.
- Owner-authorized location, when permission is granted.
- Device activity timestamps and connection history.

Location access must remain visible, permission-based and revocable by the device owner.

### Planned global architecture

```text
Windows Android Control Center
          |
          v
Secure Authenticated Connection / Relay
          |
          +--------------------------+
          |                          |
          v                          v
Android Companion App           Online Dashboard
          |                          |
          v                          v
Authorized Android Phone       Netlify / Supabase
Wi-Fi, mobile data,             Hosting, authentication,
diagnostics and permitted GPS   device records and audit logs
```

Netlify hosting alone cannot access a phone connected through local USB or ADB. Worldwide access requires a Windows agent, an Android companion application and secure remote communication.

### Feature implementation status

| Feature | Status |
|---|---|
| USB device connection | Existing |
| Local wireless ADB | Existing |
| Wireless ADB connection detection | Implemented |
| Android device diagnostics | Implemented; expansion planned |
| Windows Wi-Fi adapter detection | Tested |
| Android Wi-Fi diagnostics | Planned |
| Automatic Wi-Fi QR scanning | Planned |
| QR network name and password decoding | Planned |
| Password reveal interface | Planned |
| Android mobile-data diagnostics | Planned |
| Windows cellular diagnostics | Planned |
| Worldwide remote connectivity | Planned |
| Secure remote relay | Planned |
| Android companion application | Planned |
| Remote device monitoring | Planned |
| Owner-authorized remote location | Planned |
