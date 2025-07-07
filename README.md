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
git clone https://github.com/shepherrrd/ClipboardManager.git
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

1. [⬇️ Download the latest `.dmg` file here](https://github.com/shepherrrd/homebrew-clipboard-manager/releases/latest)
2. Open the `.dmg` and drag **ClipBoardManager.app** into **Applications**
3. Press `Control + V` anywhere to use the app 🎉

---

## 🍺 Install via Homebrew (optional)

If you have [Homebrew](https://brew.sh) installed, you can install using:

```bash
brew tap shepherrrd/clipboard-manager
brew install --cask clipboard-manager
```

> You can now launch it from Spotlight or by pressing `Control + V`

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
