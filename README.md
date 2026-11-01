 <img width="3509" height="4963" alt="busypro_max_poster" src="https://github.com/user-attachments/assets/d2d70446-75cf-4bc7-9bfc-02ba00b296e5" />

# BusyProMax
#DEMO VIDEO

https://github.com/user-attachments/assets/cf87d3b8-fbb8-41fa-95f2-b8b85a31aa1b

#Emulator-Home-View
<img width="640" height="1422" alt="emulator_home" src="https://github.com/user-attachments/assets/b1fabb6f-4bdc-4f42-9e17-701cf0e1344c" />
 

BusyProMax is a monochrome Flutter companion for quieter moments — walking
across campus, waiting between classes, or simply wanting somewhere calm to put
your attention. Six activities are available in one or two taps.

The design is deliberately black and white: Tinos (a Times New Roman-style
serif) for editorial headings, clean system sans-serif type for UI, thin rules,
subtle borders, generous whitespace, and Instagram-inspired messaging layout.
The home screen opens directly on a small "look busy" image collage and a grid
of six photographic activity cards, with no wordmark or tagline. The app is not
affiliated with Instagram, Meta, Amazon, FoodNeverComes, Hugging Face, or
Pinterest.

## Activities

| Activity | What opens | Honest boundary |
| --- | --- | --- |
| **Video Call** | A real, permission-gated camera preview with a simulated call screen, timer, mic/camera controls, and an end button. | No second person is connected. No audio or video leaves the device. The microphone is never requested. |
| **Instagram Messages** | A local demo inbox with four fictional conversations, search, avatars, bubbles, timestamps, and a local composer. An optional Hugging Face token turns on AI replies. | Not connected to Instagram. Messages are never delivered. AI replies are labeled, and the chat is sent to Hugging Face only while AI replies are on. |
| **Texting** | An SMS-style demo inbox with quick thread switching and a local composer. | No SMS permission is requested. Nothing is sent. |
| **Order Food** | `https://foodnevercome.com/` in a guarded in-app WebView. | The real website opens. BusyProMax cannot place or confirm an order. |
| **Browse & Shop** | `https://www.amazon.com/` in a guarded in-app WebView. | The real storefront opens. BusyProMax never completes a purchase or payment. |
| **Villa Security** | A bundled, pre-generated AI camera loop with a security-camera frame, live clock, scanline treatment, pause/restart, and a clear **AI DEMO** label. | It is not a live feed, does not open the camera, and is not connected to any villa or security system. |

Favorites and the chosen theme are saved locally with `shared_preferences`.
Demo conversations live in memory and reset when the app restarts (or from
**Settings → Reset**). The optional Hugging Face token is kept in the platform's
secure storage. There is no account, backend, analytics, advertising, or
tracking SDK.

## AI replies (optional)

The messaging demos can reply with a Hugging Face model instead of the bundled
sample lines.

1. Create a Hugging Face account at <https://huggingface.co/>.
2. Open **Settings → Access Tokens** and create a token with Inference
   Providers access.
3. In BusyProMax, open **Settings → AI replies → Connect**, paste the token, and
   save.
4. Open a demo conversation and send a message. The reply arrives as a labeled
   **AI REPLY** with a typing indicator.

The app calls Hugging Face's OpenAI-compatible router at
`https://router.huggingface.co/v1/chat/completions` using
`Qwen/Qwen3-4B-Instruct-2507`, with `Qwen/Qwen2.5-7B-Instruct` as a fallback.
The token is sent only in the `Authorization` header to that single host. The
last ten messages, the contact name, and a short persona prompt are sent to
produce the reply. Replies are limited to a short text message.

No token or no connection? The app falls back to the offline sample engine and
labels those lines **LOCAL SAMPLE**. Every incoming demo line is marked either
**AI REPLY** or **LOCAL SAMPLE**. Nothing is presented as a delivered SMS or
Instagram message.

Hugging Face may require Inference Providers credits for a model. If the token
is rejected, the account has no credits, or the model is unavailable, the chat
shows a short error above the composer and keeps the local transcript.

## Moodboard

The home screen includes a small, image-led moodboard labelled **Look busy**,
inspired by Pinterest's collage feel. The photographs are bundled locally,
shown in monochrome, and credited in **Settings → Media credits**. Activity
cards use their own bundled photographs rather than generic icons. There is no Pinterest API, scraping,
login, or network request. Pinterest is not affiliated with this project.

## Requirements

- Flutter **3.47.8** / Dart **3.13.7** (or a compatible stable SDK)
- Android SDK with compile SDK 36 for Android builds, minSdk 24
- Xcode 15+ and CocoaPods for iOS builds (macOS only)
- A device or emulator with a camera for the full Video Call preview
- Internet access for the two external website activities and, when enabled,
  Hugging Face AI replies

The app targets Android and iOS. It is not configured as a web or desktop
application because `webview_flutter`, `camera`, and `video_player` need a
mobile platform implementation.

## Quick start

```bash
cd busypro_max
flutter pub get
flutter run
```

Use `flutter devices` to list targets, then `flutter run -d <device-id>` if more
than one is connected.

### Android emulator or phone

1. Enable **Developer options** and **USB debugging** on the phone, or create an
   AVD in Android Studio.
2. For camera testing in an Android emulator, open the AVD's settings and set
   **Camera → Front** (and/or Back) to **VirtualScene** or your webcam.
3. Check the target is visible:
   ```bash
   flutter devices
   ```
4. Launch:
   ```bash
   flutter run -d <device-id>
   ```
5. Open **Video Call** and accept the operating-system camera prompt. If you
   decline, the screen offers **Continue without preview** so the rest of the
   simulated call still works.
6. Open **Villa Security** to check the bundled loop and its controls. The loop
   is muted and loops locally; no camera permission is involved.

### iOS device or simulator

On macOS:

```bash
flutter pub get
cd ios
pod install        # only if the project uses CocoaPods
cd ..
flutter run -d <device-id>
```

The simulator has no real camera and will show the preview-unavailable state.
Test the camera on a physical iPhone. Signing and a development team must be
configured in Xcode for a device build.

## Builds

```bash
# Local debug APK
flutter build apk --debug

# Release APK (configure a real signing key before distributing)
flutter build apk --release

# iOS archive (macOS + Xcode signing required)
flutter build ipa
```

The APKs are written to `build/app/outputs/flutter-apk/`.

### Install the ready APK on a phone

With USB debugging enabled and the phone connected:

```bash
D:\busypro-tools\android-sdk\platform-tools\adb.exe install -r \
  D:\busypro-tools\busypro_max\build\app\outputs\flutter-apk\app-release.apk
```

Alternatively, copy `app-release.apk` to the phone and open it, allowing
"Install unknown apps" for the file manager when prompted. The app appears as
**BusyProMax** in the launcher.

The Flutter template currently signs release builds with the debug key so that
release-mode testing works. Replace `android/app/build.gradle.kts`'s signing
configuration with your own release keystore before publishing.

## Verification

```bash
flutter analyze
flutter test
```

The repository includes **19 tests** covering local favorites/theme
persistence, demo messages and reset, the six-card home, bottom navigation,
theme switching, camera-failure fallback in the simulated call, the local AI
fallback, Hugging Face request/response and model fallback, the bundled villa
loop asset, the villa screen's AI labels and controls, safe web fallback, a
narrow 320px-wide layout, and the guarantee that starring an activity does not
open it.

Widget tests cannot run the native camera, WebView, or video plugins. Verify
these on a device:

- grant camera permission and confirm the preview appears, the timer runs, and
  the **End** control returns home;
- deny camera permission and confirm **Continue without preview** works;
- open **Villa Security** and confirm the loop plays, pauses, restarts, and is
  labeled **AI DEMO** and **PRE-GENERATED · NOT LIVE**;
- open each of FoodNeverComes and Amazon and check loading, retry, in-page back,
  reload, and **Open in system browser**;
- add a Hugging Face token and confirm an **AI REPLY** appears, then remove it
  and confirm the **LOCAL SAMPLE** fallback;
- toggle **Light**, **Dark**, and **System** in Settings and restart to confirm
  persistence;
- add a favorite and use **Reset** to confirm favorites clear and the sample
  conversations return.

## Platform configuration

### Android (`android/`)

- `INTERNET` permission for the in-app browser and optional AI replies.
- `CAMERA` permission for the local preview; the camera is optional at the
  hardware level, so devices without one can still install the app.
- Cleartext HTTP is disabled (`android:usesCleartextTraffic="false"`).
- `minSdk = 24`; the Flutter toolchain chooses the current compile/target SDK.
- **No `RECORD_AUDIO` permission** is declared. The camera plugin's optional
  audio and legacy-storage entries are explicitly removed during manifest
  merging, and its required `camera.any` feature is replaced by an optional
  camera declaration.
- The WebView is provided by `webview_flutter_android`.
- `INTERNET` and `CAMERA` are the only user-facing permissions in the built APK;
  Android's internal dynamic-receiver and network-state entries come from the
  Flutter/WebView runtime. The video plugin's optional `WAKE_LOCK` entry is
  stripped because only a short foreground loop is played.

### iOS (`ios/`)

- `NSCameraUsageDescription` explains that the camera is only used for the
  private simulated-call preview.
- **No `NSMicrophoneUsageDescription`** is present.
- Minimum deployment target is the Flutter template's iOS 15.0.
- The WebView uses `WKWebView` through `webview_flutter_wkwebview`.
- The Hugging Face token uses the iOS Keychain through `flutter_secure_storage`;
  `ios/Runner/Runner.entitlements` enables Keychain Sharing for all three build
  configurations.

## Project structure

```text
lib/
  main.dart                 Loads local state and launches the app
  app.dart                  MaterialApp, monochrome themes, system chrome
  theme/app_theme.dart      Palette, typography, component themes
  models/
    activity.dart           The six-activity catalog and URLs
    demo_thread.dart        Demo conversation + message models
  data/demo_content.dart    Clearly fictional sample conversations
  state/app_state.dart      Favorites, theme, local messages, reset
  services/
    ai_chat_service.dart    Hugging Face chat-completions client + fallback
    ai_key_store.dart       Secure-storage token handling
    local_reply_engine.dart Offline sample replies
  routing/                  Named routes and the fade/lift page transition
  screens/
    root_shell.dart         Persistent Home/Activities/Favorites/Settings tabs
    home_screen.dart        Image-led landing + photographic activity grid
    activities_screen.dart  Grouped list of on-device and web activities
    favorites_screen.dart   Saved activities + empty state
    settings_screen.dart    Theme, AI, permissions, privacy, reset, licenses
    video_call_screen.dart  Camera lifecycle, denial states, simulated call
    villa_security_screen.dart  Bundled AI loop + camera-style overlay
    web_activity_screen.dart    Guarded WebView + browser fallback
    conversation_list_screen.dart  Shared inbox layout for both messaging modes
    messages_screen.dart    Instagram-inspired demo
    texting_screen.dart     SMS-style demo
    chat_screen.dart        Bubbles, composer, AI replies, quick thread switcher
  widgets/                  Reusable navigation, cards, headers, notices,
                            AI token sheet, offline moodboard
test/                       State, AI service, asset, and widget tests
assets/fonts/               Bundled Tinos family + SIL OFL license
assets/images/              Bundled moodboard and activity photography (Unsplash)
assets/video/               Pre-generated AI villa loop + poster
assets/branding/            Source app icon artwork
```

## External browser behavior

FoodNeverComes and Amazon open inside `webview_flutter`'s native WebView. The
screen shows the real domain, an activity-specific disclosure, a loading state,
retry, in-page back, reload, and an **Open in system browser** escape hatch.
HTTP and HTTPS navigation is allowed; other URL schemes (`intent:`, `tel:`,
`mailto:`, custom app schemes) are blocked for safety.

Some websites refuse embedded browsers, require a login, or challenge bot
traffic. In that case the error screen and system-browser fallback are the
supported path. Website content is controlled by those services and is subject
to their own privacy policies and cookies. BusyProMax does not inject order,
purchase, or message confirmations into any external page.

### External availability (checked 28 Oct 2026)

- **FoodNeverComes** responds successfully.
- **Amazon** responds, but may present a sign-in or bot challenge inside a
  WebView; the system-browser fallback is available.
- **Villa Videos** (`www.villa-videos.com`) was serving an expired and revoked
  TLS certificate. The app no longer embeds it: Villa Security uses the bundled
  AI loop instead, and the app never bypasses a bad certificate.

## The villa loop

`assets/video/villa_garden_loop.mp4` is a **4.8-second, 768×512, 24 fps H.264**
loop generated with the LTX-Video model via Hugging Face, then converted to a
muted, looping mobile asset. The poster frame is
`assets/video/villa_garden_poster.jpg`. The screen labels it **AI DEMO**,
**SIM**, and **PRE-GENERATED · NOT LIVE**; it never opens the camera and never
claims to be a real security system. Because the clip is bundled, it works with
no network connection.

## Permissions and privacy

- **Camera** is requested only by the camera plugin when Video Call initializes.
  It is not requested at launch. If denied, the preview-less call screen remains
  usable.
- **Microphone** is never requested or recorded. `CameraController` is created
  with `enableAudio: false`, and the mic control is explicitly described as a
  visual demo control.
- **No contacts, SMS, location, photos, notifications, or background services**
  are used.
- Favorites and theme are stored in local preferences. Demo messages are
  in-memory only. A Hugging Face token, if added, is stored in platform secure
  storage.
- Network activity: the two external websites you choose to open, and Hugging
  Face only when AI replies are enabled. There is no analytics or telemetry.
- Remove the token in **Settings → AI replies → Manage → Remove** at any time.

## Responsible design

BusyProMax is a comfort and confidence tool, not a system for deceiving another
person. Every simulation is labeled in the UI:

- **Video Call** says “No one is connected,” shows no fake remote participant,
  and explains that the camera preview is local.
- **Messages** and **Texting** carry a persistent demo banner; composers state
  that nothing is sent. AI replies are labeled **AI REPLY**, and offline sample
  replies are labeled **LOCAL SAMPLE**.
- **Villa Security** is a bundled AI loop labeled **AI DEMO** and
  **PRE-GENERATED · NOT LIVE**; it does not access a camera or a real feed.
- **Order Food** and **Browse & Shop** load the actual public websites and make
  no claim that an order or purchase exists.
- No fake delivered-order confirmation, sent-message receipt, incoming call, or
  live security footage is generated.

Real Instagram messaging, SMS, phone calls, ordering, or payments are not
implemented. Adding one would require the provider's official APIs, explicit
authentication, and a clear permission flow.

## Font and media licenses

Tinos is bundled under the SIL Open Font License 1.1; the full license is at
[`assets/fonts/OFL.txt`](assets/fonts/OFL.txt). The app icon is original
BusyProMax artwork generated from that typeface. Moodboard photographs are from
Unsplash under the Unsplash License. The villa loop is AI-generated with
LTX-Video (Lightricks) via Hugging Face. Media credits are also listed in
**Settings → Media credits**.

## This Windows checkout

The project was developed on a machine with limited C: space, so the SDK and
build caches live on D:. The workspace contains `busypro_max/` as a directory
junction to `D:\busypro-tools\busypro_max`.

For a new terminal, set:

```powershell
$env:PATH = "D:\busypro-tools\flutter\bin;$env:PATH"
$env:ANDROID_HOME = "D:\busypro-tools\android-sdk"
$env:JAVA_HOME = "D:\rea-tools\jdk-21.0.12.1+1"
$env:PUB_CACHE = "D:\busypro-tools\pub-cache"
$env:GRADLE_USER_HOME = "D:\busypro-tools\gradle-home"
```

Then:

```powershell
cd D:\busypro-tools\busypro_max
flutter pub get
flutter run
```

On a normal machine with Flutter and an Android SDK already installed, none of
these paths are required; use `flutter run` from the project directory.
