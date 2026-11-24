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
| Wireless connection management | Incomplete |
| Device authorization modules | Incomplete |
| Android companion application | Planned |
| Local web dashboard | Planned |
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

The web directory will be introduced when web development begins.

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
