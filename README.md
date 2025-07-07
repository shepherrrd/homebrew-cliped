# 📋 Clipboard Manager for macOS

A minimal and slick clipboard history manager that pops up when you press **Control + V**, just like Windows Clipboard History. Built in Swift using SwiftUI and AppKit.

- ⌨️ Global hotkey: `⌃ Control + V`
- 🧠 Remembers clipboard history between sessions
- ✅ Auto-closes on selection
- 🔁 Avoids duplicate entries
- 🚀 Launches on login
- 💾 Light and native — no Electron

---

## 🚀 Features

- 🕶️ Clean, native macOS UI
- 🔒 Sandboxed, with no private APIs
- 💻 Works entirely offline
- 🧰 Built with Swift + AppKit + SwiftUI

---

## 🛠️ Running the App Locally

To run the app locally, clone this repo and open the project in Xcode:

```bash
git clone https://github.com/shepherrrd/homebrew-cliped.git
cd ClipboardManager
open ClipBoardManager.xcodeproj
```

Then:

1. Select **`My Mac`** as the target device.
2. Press **Run** ▶️ or `Cmd + R`.
3. Press `Control + V` to show the clipboard popup.

> The app auto-captures your clipboard and shows recent history in a minimal window. Selecting an item will paste and auto-close.

---


## 💻 System Requirements

- macOS 12.0 Monterey or later
- M1/M2/M3 or Intel chip
- Xcode 14+ (for building locally)

---

## 📦 Installation via DMG

You can install the app using the `.dmg` installer:

1. [⬇️ Download the latest `.dmg` file here](https://github.com/shepherrrd/homebrew-cliped/releases/latest)
2. Open the `.dmg` and drag **ClipBoardManager.app** into **Applications**
3. Press `Control + V` anywhere to use the app 🎉

---

## 🍺 Install via Homebrew (optional)

If you have [Homebrew](https://brew.sh) installed, you can install using:

```bash
brew tap shepherrrd/cliped
brew install --cask cliped
```
### 🛡 macOS Gatekeeper Notice

If you see the error:

> **“Cliped” cannot be opened because Apple cannot check it for malicious software.**

This is expected since **Cliped** is a free and open-source app not yet notarized by Apple.

#### ✅ How to Open It Anyway:

1. **Try opening Cliped** by double-clicking it. You'll see a warning.
2. Open **System Settings** → **Privacy & Security**.
3. Scroll down to the **Security** section.
4. You should see a message like:
   > `"Cliped" was blocked from use because it is not from an identified developer.`
5. Click **🟢 Open Anyway**.
6. A new dialog will appear. Click **Open** to confirm.

> This process only needs to be done once. After that, Cliped will open normally.

---

💡 We're working on making Cliped [notarized and universal](https://developer.apple.com/documentation/security/notarizing_macos_software_before_distribution), but in the meantime, this is the safest workaround for early users.

> You can now launch it from Spotlight or by pressing `Control + V`

---

## 🔄 Updating Cliped to the Latest Version

If you've already installed Cliped via Homebrew and want to update to the latest version, follow these steps:

### 1. 🧼 Uninstall the old version
Remove the currently installed version of Cliped:

```bash
brew uninstall --cask cliped
```

---

### 2. 🔁 Update Homebrew

Make sure your Homebrew repositories are up to date:

```bash
brew update
brew upgrade
```

---

### 3. ⬇️ Reinstall the latest version of Cliped

Now, reinstall Cliped from the latest release:

```bash
brew install --cask cliped
```

If you already have it installed and just want to force an update:

```bash
brew reinstall --cask cliped
```

---

### 4. 🧠 (Optional) Check if a newer version is available

You can check whether your installed version is outdated using:

```bash
brew outdated
```

---

## 📂 App Behavior

- Remembers history using UserDefaults
- Launches at login (via AppDelegate)
- Persists clipboard items unless cleared
- Supports images and text content

---

## 🛡️ Security

- No clipboard data is sent online
- Sandbox-safe
- Fully native and open source

---

## 🧪 Development Notes

- Built with: `Swift`, `AppKit`, `SwiftUI`
- Keyboard hook using `EventTap`
- Global hotkey via `Carbon` and `IOKit`

---

## 🤝 Contributions

Pull requests and stars are welcome!

---

## 📄 License

MIT © 2025 [@shepherrrd](https://github.com/shepherrrd)
