# 🚨 AERO-SOS — Autonomous Drone Emergency Dispatch Mobile Application

[![Flutter](https://img.shields.io/badge/Flutter-3.47+-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13+-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi&logoColor=white)](https://fastapi.tiangolo.com)
[![WebSocket](https://img.shields.io/badge/Telemetry-WebSocket-green)](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A standalone, high-performance Flutter mobile application designed for instant emergency beacon broadcasting and real-time autonomous rescue drone dispatch. 

Built with a **tactical high-contrast dark theme**, native device **GPS geolocation**, interactive **OpenStreetMap GIS mapping (`flutter_map`)**, live bidirectional **WebSocket telemetry streaming**, and **Dual Tamil (தமிழ்) + English** interface labels.

---

## 📑 Table of Contents
1. [Key Features](#-key-features)
2. [How to Connect Mobile App to Backend Server](#-how-to-connect-mobile-app-to-backend-server)
3. [How to Install the App on Mobile (3 Methods)](#-how-to-install-the-app-on-mobile)
4. [Step-by-Step Usage Guide](#-step-by-step-usage-guide)
5. [Project Architecture](#-project-architecture)
6. [Troubleshooting & FAQs](#-troubleshooting--faqs)

---

## ⚡ Key Features

- **Dual-Language Interface (தமிழ் + English):** Built-in bilingual support across all alerts, categories, profile fields, and status badges.
- **Phone & OTP Authentication:** Fast mobile verification with an instant 1-tap **Demo OTP Auto-Fill** card for rapid demonstrations.
- **Emergency Medical Profile:** Persistent user profile storing Full Name, Age, Gender, Blood Group chips (A+, B+, O+, AB+, etc.), and Emergency Contact details.
- **Tactical OpenStreetMap GIS Dashboard:** Real-time location tracking using device GPS (`geolocator`) with dynamic visual map pins.
- **Tactile Pulsating SOS Radar Beacon:** Animated crimson radar ripple button designed for high-stress emergency triggers.
- **6 Emergency Categorization Cards:** Medical (மருத்துவம்), Fire (தீ விபத்து), Flood (வெள்ளம்), Accident (விபத்து), Security (பாதுகாப்பு), and Other (பிற).
- **Live Drone Mission Telemetry:** 4-stage real-time stepper powered by WebSockets:
  1. `SOS_RECEIVED` (உதவி கோரப்பட்டது)
  2. `SEARCHING_FOR_DRONE` (ட்ரோன் தேடப்படுகிறது)
  3. `DRONE_ASSIGNED` (ட்ரோன் ஒதுக்கப்பட்டது — displays Drone ID, ETA, battery %, altitude, and live flight trajectory)
  4. `WAITING_FOR_OPERATOR_APPROVAL` (ஆபரேட்டர் ஒப்புதலுக்காக காத்திருக்கிறது)
- **Mission Abortion / Cancel SOS:** Real-time mission cancellation button to abort drone dispatch if the alert was accidental.

---

## ⚙️ How to Connect Mobile App to Backend Server

The mobile app communicates with the FastAPI backend server located in the `sos-app/` directory for authentication, emergency dispatch, and live WebSocket telemetry.

### Step 1: Ensure Same Wi-Fi Network
Make sure both your **Computer (running the backend server)** and your **Mobile Phone** are connected to the **same Wi-Fi router / mobile hotspot**.

### Step 2: Start the Backend Server on your PC
Open a terminal on your computer and start the server:
```powershell
cd "sos-app"
python server.py
```
*(You will see: `INFO: Uvicorn running on http://0.0.0.0:8000`)*

### Step 3: Find your PC's Local IP Address
In another terminal on your computer, find your local IPv4 address:
- **Windows (PowerShell/CMD):**
  ```powershell
  ipconfig
  ```
  *(Look for `IPv4 Address` under your active Wi-Fi adapter, e.g., `192.168.1.15` or `172.27.140.178`)*
- **macOS / Linux:**
  ```bash
  ifconfig -a   # or: ip a
  ```

### Step 4: Configure the Server URL in the Mobile App
1. Open the **AERO-SOS** app on your phone.
2. On the **Login Screen**, tap the **⚙️ (Settings)** icon in the top-right corner.
3. Enter your PC's IP address with port `8000`:
   ```text
   http://<YOUR_PC_IP>:8000
   ```
   *(Example: `http://172.27.140.178:8000` or `http://192.168.1.15:8000`)*
4. Tap **Save**. The app will now communicate directly with your local server!

> **Note for Android Emulator:** If testing inside an Android Studio emulator, use the default loopback address: `http://10.0.2.2:8000`.

---

## 📲 How to Install the App on Mobile

Choose any of the 3 installation methods below:

### Method 1: Direct APK File Installation (Recommended)

1. **Build the APK:**
   Inside the `sos_mobile_app` folder, run:
   ```bash
   flutter build apk --debug
   ```
   *(For an optimized release build: `flutter build apk --release`)*

2. **Locate the APK file:**
   The compiled APK file is saved at:
   ```
   sos_mobile_app/build/app/outputs/flutter-apk/app-debug.apk
   ```

3. **Transfer the APK to your phone:**
   - **Via USB Cable:** Plug your phone into your PC and copy `app-debug.apk` to your phone's **Downloads** folder.
   - **Via WhatsApp / Telegram / Google Drive:** Upload the APK to yourself on WhatsApp Web or Drive, then tap Download on your phone.
   - **Via 1-Click Wi-Fi Server (Instant):**
     Run a quick local web server on your PC:
     ```bash
     cd "build/app/outputs/flutter-apk"
     python -m http.server 8080
     ```
     On your mobile Chrome browser, navigate to `http://<YOUR_PC_IP>:8080/app-debug.apk` to download directly in 1 click!

4. **Install on Phone:**
   Open the downloaded `.apk` on your phone. If prompted, enable **"Install unknown apps / Allow from this source"** in Android Settings, then tap **Install**.

---

### Method 2: Live USB Debugging Run (For Developers)

1. On your Android phone, enable **Developer Options**:
   - Go to **Settings ➔ About Phone ➔ Tap 'Build Number' 7 times**.
2. Go to **Settings ➔ Developer Options** and enable **USB Debugging**.
3. Connect your phone to your PC via USB cable and allow USB debugging when prompted on the screen.
4. Verify the device is detected:
   ```bash
   flutter devices
   ```
5. Run the application:
   ```bash
   flutter run
   ```
   *The app will automatically compile, install, and launch on your phone with Flutter Hot Reload enabled.*

---

### Method 3: Instant Browser Preview (Web Mode)

To test the mobile interface instantly without installing an APK:
```bash
flutter run -d chrome
```
*Or to view on mobile browser via Wi-Fi:*
```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 3000
```
Open `http://<YOUR_PC_IP>:3000` on your mobile phone's Chrome browser.

---

## 🧪 Step-by-Step Usage Guide

```
+----------------+      +----------------+      +----------------+      +-------------------+
|  1. Login &    | ---> |  2. Complete   | ---> |  3. Tactical   | ---> |  4. Live Drone    |
|   Verify OTP   |      |  Medical Info  |      |   SOS Trigger  |      |  Telemetry Stepper|
+----------------+      +----------------+      +----------------+      +-------------------+
```

### 1. Authentication Screen
- Enter any mobile number (e.g. `+919876543210`) and tap **OTP கோருக / REQUEST OTP**.
- An instant **DEMO OTP CODE** card will appear. Tap **"தானாக நிரப்பு / Fill"** to automatically insert the 6-digit OTP code, then tap **உள்நுழைக / VERIFY**.

### 2. User Profile Setup
- For first-time users, enter your **Full Name**, **Age**, select your **Gender**, and tap your **Blood Group chip** (e.g., `O+`, `A+`).
- Add an emergency contact phone number and tap **சேமி & தொடர்க / SAVE & CONTINUE**.

### 3. Tactical Emergency Dashboard
- The live interactive map centers on your current GPS location (with fallback demo coordinates if GPS is unavailable).
- Select the applicable emergency category card:
  - 🏥 **Medical / மருத்துவம்**
  - 🔥 **Fire / தீ விபத்து**
  - 🌊 **Flood / வெள்ளம்**
  - 🚗 **Accident / விபத்து**
  - 🛡️ **Security / பாதுகாப்பு**
  - ⚠️ **Other / பிற**
- Add optional details in the notes box (e.g., *"Cardiac arrest, 2nd floor"*).
- Tap the glowing pulsating **SOS button** to trigger autonomous drone dispatch.

### 4. Live Drone Mission Telemetry
- Your device automatically establishes a persistent **WebSocket stream** (`/ws/sos/{sos_id}`).
- Watch real-time stage progression:
  - 🚨 **SOS Received:** Dispatch queue acknowledges beacon.
  - 📡 **Searching for Drone:** Hangar telemetry locates nearest autonomous drone.
  - 🛸 **Drone Assigned:** Real-time drone status card appears with **Drone ID (`DRONE-AERO-07`)**, **Estimated Arrival Time (ETA)**, **Battery level**, **Altitude**, and **Flight Route coordinates**.
  - ⏳ **Waiting for Operator Approval:** Flight corridor verified by safety command.
- Tap **ரத்து செய் / CANCEL SOS** at any time to abort the emergency mission.

---

## 📂 Project Architecture

```
sos_mobile_app/
├── android/                     # Native Android project & permissions (GPS, Internet)
├── lib/
│   ├── main.dart                # App entrypoint & persistent session check
│   ├── theme/
│   │   └── app_theme.dart       # Tactical dark palette, colors, and Material 3 styles
│   ├── models/
│   │   ├── user_model.dart      # User profile serialization & storage
│   │   └── sos_model.dart       # SOS payload & Drone telemetry models
│   ├── services/
│   │   ├── api_service.dart     # HTTP REST client with configurable backend host URL
│   │   ├── websocket_service.dart # WebSocket stream client for live drone dispatch
│   │   └── location_service.dart  # Native GPS geolocation wrapper with fallback
│   ├── widgets/
│   │   ├── sos_radar_button.dart  # Custom animated circular red button with radar ripples
│   │   ├── emergency_card.dart    # 6 selectable category cards with dual labels
│   │   └── profile_dialog.dart    # Profile modal with quick call & Server IP configurator
│   └── screens/
│       ├── auth_screen.dart       # Phone & OTP verification screen
│       ├── profile_screen.dart    # First-time user profile setup screen
│       ├── home_screen.dart       # Tactical dashboard with Leaflet map & SOS beacon
│       └── tracking_screen.dart   # Live mission tracking & drone telemetry timeline
└── pubspec.yaml                 # Dependencies (flutter_map, geolocator, http, web_socket_channel)
```

---

## ❓ Troubleshooting & FAQs

### Q1: The app says "Connection Refused" or "Failed host lookup" when requesting OTP.
- **Cause:** The mobile app cannot reach your PC's IP address.
- **Fix:**
  1. Verify the backend server is running on your PC (`python server.py`).
  2. Confirm your PC and Phone are on the **exact same Wi-Fi network**.
  3. Check Windows Firewall: Ensure port `8000` is allowed through Windows Defender Firewall, or temporarily disable private network firewall for testing.
  4. In the app login screen, tap ⚙️ and verify you entered `http://<YOUR_PC_IP>:8000` (do not use `localhost` or `127.0.0.1` on a physical phone).

### Q2: Android shows "Blocked by Play Protect" or "Unknown app" when installing the APK.
- **Cause:** Android protects against side-loaded `.apk` files not downloaded from Google Play Store.
- **Fix:** Tap **"More details" ➔ "Install anyway"**.

### Q3: Location permission denied on physical phone.
- **Fix:** The app requests Android `ACCESS_FINE_LOCATION`. If denied, go to your phone's **Settings ➔ Apps ➔ AERO-SOS ➔ Permissions ➔ Location ➔ Allow while using app**. If GPS is offline, the app automatically switches to safe demo location mode.

---

## 📄 License
This project is licensed under the MIT License — see the LICENSE file for details.
