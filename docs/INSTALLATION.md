# Android Control Center - Installation Guide

This guide separates requirements for the existing Windows application from additional requirements for the planned web and Android components.

## 1. Windows System Requirements

Recommended:

- Windows 10 or Windows 11, 64-bit.
- Windows PowerShell 5.1.
- Administrator access when installing system-wide dependencies.
- USB cable for device connection.
- Modern Android device with USB debugging support.

Verified development environment:

- Windows build 22631.
- PowerShell 5.1.22621.6133.
- AMD64 architecture.
- Git installed.
- ADB 37.0.3.
- scrcpy 5.0.1.
- Android SDK platform android-37.0.
- Android Studio bundled Java runtime installed.

These are the detected development environment versions, not minimum supported versions.

## 2. Install Git

Download Git for Windows:

https://git-scm.com/download/win

Verify:

```powershell
git --version
```

## 3. Install ADB and scrcpy

Download Android SDK Platform Tools:

https://developer.android.com/tools/releases/platform-tools

Install scrcpy:

https://github.com/Genymobile/scrcpy

Verify:

```powershell
adb version
scrcpy --version
```

The current Windows application searches for:

- adb.exe on PATH or in the project's platform-tools directory.
- scrcpy.exe on PATH or beside the main PowerShell script.

If these programs are not on PATH, configure their locations before launching the application.

The application displays an error if either executable cannot be found.

## 4. Prepare an Android Device

On the Android device:

1. Open Settings.
2. Open About phone.
3. Locate Build number.
4. Tap Build number seven times if required.
5. Return to Settings.
6. Open Developer options.
7. Enable USB debugging.
8. Connect the device to Windows.
9. Accept the computer authorization prompt on the device.

Verify:

```powershell
adb devices
```

Only use devices you own or are authorized to manage.

## 5. Install Android Studio

Download:

https://developer.android.com/studio

During setup:

- Choose the Standard installation.
- Accept the required SDK licenses.
- Install Android SDK Platform Tools.
- Install an appropriate Android SDK platform.
- Install Android SDK Build Tools.

Android Studio includes its own Java runtime.

The inspected development environment already contains an Android Studio Java runtime and Android SDK. Java and Gradle are not currently available as standalone commands on PATH.

A separate Gradle installation is not necessary when a future Android project uses the Gradle Wrapper.

## 6. Launch Android Control Center

Open PowerShell:

```powershell
cd C:\Users\User\AndroidControlCenter
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\AndroidControlCenter.ps1
```

The main application uses Windows Forms and loads:

```text
gui/ManufacturerIntegration.ps1
```

Do not move the main application without preserving its relative GUI module structure.

## 7. Web Development Requirements (Planned)

The website and backend have not yet been implemented.

Install a currently supported Node.js LTS release:

https://nodejs.org/

npm is included with Node.js.

Verify:

```powershell
node --version
npm --version
```

### Planned web project structure

```text
web/
├── frontend/
├── backend/
├── shared/
└── README.md
```

The final structure may change during implementation.

### Local website installation

The future local installation will include:

1. Node.js and npm.
2. Backend dependencies.
3. Local environment configuration.
4. Local database or approved storage.
5. Local API service.
6. Browser dashboard.

Local functions should remain available without an internet connection where practical.

### Online website installation

The proposed hosting architecture uses:

- Netlify for frontend hosting.
- Supabase for authentication and database services.
- HTTPS for remote communication.
- An authenticated Windows agent for device operations.

Online deployment will require:

- A domain name if a custom domain is desired.
- Hosting configuration.
- Supabase project configuration.
- Secure environment variables.
- Authentication policies.
- Device authorization.
- Audit logging.

Never expose ADB, SSH or other device-control ports directly to the public internet.

## 8. Android Companion Application (Planned)

The companion application will be developed separately using Android Studio and Kotlin.

Planned functions include:

- Device information.
- Permission-aware SIM diagnostics.
- Supported telephony information.
- Authorized device registration.
- Permission-based location reporting.
- Device monitoring.

Android restricts access to protected identifiers such as IMEI. The application must report restricted or unavailable information honestly rather than bypassing platform protections.

## 9. Configuration and Security

Do not commit:

- ConnectionSettings.json.
- trusted-devices.json.
- Private SSH keys.
- Passwords.
- API tokens.
- Local logs.
- Backups.
- Production environment files.

Use example configuration files containing placeholders only.

Review .gitignore before staging files.

## 10. Troubleshooting

### ADB not found

```powershell
Get-Command adb -ErrorAction SilentlyContinue
adb devices
```

Ensure Android SDK Platform Tools are installed and available.

### scrcpy not found

```powershell
Get-Command scrcpy -ErrorAction SilentlyContinue
scrcpy --version
```

Ensure scrcpy is installed and discoverable.

### Device unauthorized

- Unlock the Android device.
- Check the USB debugging authorization prompt.
- Reconnect the cable.
- Run adb devices again.

### PowerShell application does not open

Check:

- Windows PowerShell version.
- Windows Forms availability.
- ADB and scrcpy locations.
- Required GUI module files.
- PowerShell error output.

### Android companion build failures

Check:

- Android Studio SDK installation.
- SDK platform availability.
- Gradle Wrapper configuration.
- Java runtime.
- Build error messages.

## 11. Installation and Development Status

The following components are present in the inspected project:

- Windows PowerShell application.
- GUI modules.
- Device diagnostic modules.
- Samsung USB engine.
- IMEI validator and limited IMEI reader.
- Recovery Center.

Some connection, SSH, backup and remote-control modules are incomplete placeholders.

The following components are not yet implemented:

- Local web dashboard.
- Online web dashboard.
- Production backend API.
- Windows web-control agent.
- Android companion application.

Installation instructions for these components will be expanded as implementation and testing are completed.
