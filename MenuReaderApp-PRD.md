# Menu Reader App — Product Requirements Document

## The Problem

You're at a dimly lit restaurant. The menu is hard to read. You pull out your phone, take a photo, but now you're juggling between Camera, Photos, and trying to zoom in while your screen blinds everyone at the table. There's no app built specifically for this moment.

## The Solution

A polished, single-purpose iOS app for capturing, enhancing, and reading restaurant menus in low light. Photos auto-delete after 24 hours — it's a tool, not an archive. Red light mode keeps the screen from disturbing your table. OCR lets you search across multiple menu pages.

---

## Name Options

All checked against the iOS App Store — no direct conflicts as of March 2026.

| Name | Why it works |
|------|-------------|
| **Carte** | French for "menu" (as in à la carte). One word, elegant, memorable. The .app domain may be available. Feels premium. |
| **Lumos** | Latin for "light" — you're literally bringing light to the menu. Short, distinctive, and evocative. |
| **Nocturn** | Short for nocturne. Communicates the low-light, evening dining context instantly. Feels moody and intentional. |
| **Mise** | From "mise en place" (everything in its place). Subtle restaurant-world nod. Very short, easy to say. |
| **Glint** | A small flash of light — exactly what the app does for your menu. One syllable, easy to remember, feels snappy. |
| **Ember** | A warm, low glow — matches the red light mode and candlelit restaurant vibe. Distinctive and evocative. |
| **Dine Lens** | More descriptive, immediately communicates purpose. Less abstract, more App Store discoverable. |

**My pick:** Lumos or Nocturn. Both communicate the core value (reading in low light), feel premium, and are distinctive enough to stand out.

---

## Core Features

### 1. Menu Capture
- **Camera**: In-app camera with auto-enhance on capture (brightness, contrast, sharpness)
- **Photo Library**: Import from Photos
- **Share Sheet**: Accept images shared from other apps (Safari, Messages, etc.)
- **Flashlight/Torch Toggle**: One-tap torch control while in the camera view — no leaving the app

### 2. Menu Viewer
- **Full-screen horizontal card swipe** between menu images
- **Pinch to zoom** with smooth gesture handling
- **Auto-enhance applied by default** on capture
- **Manual adjustment sliders**: brightness, contrast, warmth, sharpness — accessible via a tune icon overlay
- **Page indicator dots** showing position in the stack

### 3. Auto-Grouping
- Photos taken within a **configurable time window** (default: 30 minutes) are automatically grouped as one "session"
- Swipe through pages within a session, swipe between sessions
- No manual labeling — sessions are disposable and anonymous
- Visual separator between sessions in the card swipe (subtle divider or gap)

### 4. Red Light Mode
- Toggle accessible from any screen (persistent button or long-press gesture)
- When active:
  - All UI chrome shifts to deep red on black (dark red text, red-tinted icons, black backgrounds)
  - Photo viewer applies a red-safe overlay — content remains readable but doesn't blow out dark-adapted eyes
  - Status bar and navigation remain visible but in red
- Does **not** auto-dim screen brightness — user controls that
- Respects system dark/light mode (red light overrides both when active)

### 5. OCR Text Search
- On capture, run Apple Vision `VNRecognizeTextRequest` to extract text from each menu image
- Store extracted text alongside the image (same 24-hour lifecycle)
- Search bar at the top of the menu viewer — type to highlight/filter across all current menus
- Use case: "Do they have a risotto?" → type "risotto" → matching menu page surfaces with the word highlighted

### 6. Auto-Cleanup
- All menu images and their OCR text are deleted **automatically**:
  - On the **next app open** after 24 hours have passed since capture, OR
  - Immediately if the image is older than 24 hours when the app enters foreground
- Cleanup runs on `scenePhase` change to `.active`
- No manual delete required (but a "clear all" option is available)
- Countdown or "expires in X hours" subtle badge on each session (optional polish)

---

## User Flow

```
┌─────────────────────────────────────────────────┐
│                   LAUNCH                        │
│                                                 │
│  ┌─────────┐    ┌──────────┐    ┌───────────┐  │
│  │ Empty   │    │ Has      │    │ Has       │  │
│  │ State   │    │ Menus    │    │ Expired   │  │
│  │         │    │          │    │ Menus     │  │
│  └────┬────┘    └────┬─────┘    └─────┬─────┘  │
│       │              │                │         │
│       ▼              ▼                ▼         │
│  "Capture a     Card Swipe      Auto-delete,   │
│   Menu"         Viewer          then show       │
│  (CTA button)                   remaining or    │
│       │                         empty state     │
│       ▼                                         │
│  ┌──────────┐                                   │
│  │ Camera   │──── Torch Toggle                  │
│  │ View     │──── Capture → Auto-enhance        │
│  │          │──── Switch to Photo Library        │
│  └──────────┘                                   │
│                                                 │
│  ┌──────────────────────────────────────────┐   │
│  │            MENU VIEWER                    │   │
│  │                                           │   │
│  │  [Search: ___________]     [Red Light 🔴] │   │
│  │                                           │   │
│  │  ┌─────────────────────────────────────┐  │   │
│  │  │                                     │  │   │
│  │  │         Full-screen image           │  │   │
│  │  │         (pinch to zoom)             │  │   │
│  │  │                                     │  │   │
│  │  │     ← swipe ●●○ swipe →            │  │   │
│  │  │                                     │  │   │
│  │  └─────────────────────────────────────┘  │   │
│  │                                           │   │
│  │  [Adjust] [Camera+]         [Clear All]   │   │
│  │                                           │   │
│  └──────────────────────────────────────────┘   │
│                                                 │
│  ┌──────────────────────────────────────────┐   │
│  │         ADJUST PANEL (sheet)              │   │
│  │                                           │   │
│  │  Brightness  ─────●──────────  +40        │   │
│  │  Contrast    ──────────●─────  +20        │   │
│  │  Warmth      ────●───────────  -10        │   │
│  │  Sharpness   ──────●─────────  +15        │   │
│  │                                           │   │
│  │  [Reset to Auto]                          │   │
│  └──────────────────────────────────────────┘   │
└─────────────────────────────────────────────────┘
```

---

## Technical Architecture

### Stack
| Layer | Technology |
|-------|-----------|
| UI | SwiftUI (iOS 17+) |
| Architecture | MVVM |
| Persistence | SwiftData (local only, no CloudKit) |
| Image Processing | Core Image (CIFilter for brightness, contrast, warmth, sharpness) |
| OCR | Vision framework (VNRecognizeTextRequest) |
| Camera | AVFoundation (for torch control + capture) |
| Photo Import | PhotosUI (PHPickerViewController) |
| Share Extension | App Extension to accept images from other apps |

### Data Model

```swift
@Model
final class MenuSession {
    var capturedAt: Date = Date.now
    var expiresAt: Date = Date.now.addingTimeInterval(86400) // 24 hours

    @Relationship(deleteRule: .cascade, inverse: \MenuImage.session)
    var images: [MenuImage]?

    var sortedImages: [MenuImage] {
        (images ?? []).sorted { $0.sortOrder < $1.sortOrder }
    }

    var isExpired: Bool {
        Date.now > expiresAt
    }

    init() {
        self.capturedAt = .now
        self.expiresAt = Date.now.addingTimeInterval(86400)
    }
}

@Model
final class MenuImage {
    var imageData: Data = Data() // stored via @Attribute(.externalStorage)
    var extractedText: String = "" // OCR result
    var sortOrder: Int = 0
    var capturedAt: Date = Date.now

    // Enhancement settings (user overrides)
    var brightnessAdjustment: Double = 0.0
    var contrastAdjustment: Double = 0.0
    var warmthAdjustment: Double = 0.0
    var sharpnessAdjustment: Double = 0.0
    var hasManualAdjustments: Bool = false

    var session: MenuSession?

    init(imageData: Data, sortOrder: Int = 0) {
        self.imageData = imageData
        self.sortOrder = sortOrder
        self.capturedAt = .now
    }
}
```

### Key Services

**ImageEnhancementService** — Core Image pipeline
- Auto-enhance: analyze histogram, apply adaptive brightness/contrast/sharpness
- Manual adjustments via CIFilter chain: CIColorControls (brightness, contrast), CITemperatureAndTint (warmth), CISharpenLuminance (sharpness)
- Returns processed UIImage for display

**OCRService** — Vision framework
- Accepts UIImage, returns extracted text
- Runs asynchronously after capture
- Stores result on MenuImage.extractedText

**CleanupService** — Expiration logic
- Called on scenePhase → .active
- Fetches all MenuSessions where expiresAt < Date.now
- Deletes expired sessions (cascade deletes images)

**CameraService** — AVFoundation
- Camera preview + capture
- Torch on/off toggle
- Returns captured image data

### Project Structure

```
AppName/
├── App/
│   ├── AppNameApp.swift
│   └── ContentView.swift
├── Models/
│   ├── MenuSession.swift
│   └── MenuImage.swift
├── Features/
│   ├── Camera/
│   │   ├── Views/
│   │   │   └── CameraView.swift
│   │   └── CameraViewModel.swift
│   ├── MenuViewer/
│   │   ├── Views/
│   │   │   ├── MenuViewerView.swift     // horizontal card swipe
│   │   │   ├── MenuCardView.swift       // single image with zoom
│   │   │   └── AdjustmentPanel.swift    // sliders sheet
│   │   └── MenuViewerViewModel.swift
│   ├── Search/
│   │   └── Views/
│   │       └── MenuSearchView.swift     // OCR search overlay
│   └── Settings/
│       └── Views/
│           └── SettingsView.swift
├── Services/
│   ├── ImageEnhancementService.swift
│   ├── OCRService.swift
│   ├── CleanupService.swift
│   └── CameraService.swift
├── Components/
│   ├── RedLightModifier.swift           // ViewModifier for red tinting
│   └── EmptyStateView.swift
├── Extensions/
│   ├── Color+Theme.swift
│   └── Color+RedLight.swift
├── ShareExtension/                       // App Extension target
│   ├── ShareViewController.swift
│   └── Info.plist
└── Resources/
    └── Assets.xcassets
```

### Red Light Mode Implementation

Red light mode is a global `@Observable` state applied as a ViewModifier:

```swift
@MainActor
@Observable
final class AppState {
    var isRedLightMode = false
}

struct RedLightModifier: ViewModifier {
    let isActive: Bool

    func body(content: Content) -> some View {
        content
            .tint(isActive ? .red : .accentColor)
            .preferredColorScheme(.dark) // always dark when red light is on
            .overlay {
                if isActive {
                    Color.red.opacity(0.05)
                        .ignoresSafeArea()
                        .allowsHitTesting(false)
                }
            }
    }
}
```

The photo viewer applies a separate red overlay on images:
- Convert display to grayscale + red channel only
- Or: apply CIColorMatrix to zero out green/blue channels
- User can still pinch-zoom and read text — just in red tones

---

## Scope & Phases

### Phase 1 — MVP (ship this)
- Camera capture with auto-enhance
- Photo library import
- Horizontal card swipe viewer with pinch-to-zoom
- Manual adjustment sliders (brightness, contrast, warmth, sharpness)
- Auto-grouping by time window
- 24-hour auto-expiration on app foreground
- Red light mode toggle
- Torch toggle in camera

### Phase 2 — Polish
- OCR text extraction + search across menus
- Share extension (accept images from other apps)
- "Expires in X hours" badge on sessions
- Haptic feedback on mode toggles
- Onboarding (3 screens max)

### Phase 3 — Nice to Have
- Widget showing "you have X menus saved" or quick-launch to camera
- Apple Watch complication for torch toggle
- Accessibility audit (VoiceOver for OCR text reading)

---

## Design Notes

- **Vibe**: Polished but simple. Think: a beautifully designed flashlight. No clutter, no settings sprawl.
- **Color palette**: Deep blacks, warm whites, soft amber accents. Red light mode uses deep crimson (#8B0000) on true black.
- **Typography**: System rounded, slightly warm. Menu text should feel easy on the eyes.
- **Animations**: Smooth card transitions, gentle slider interactions. Nothing flashy.
- **Empty state**: Inviting, not sad. "Capture a menu to get started" with a subtle camera icon.
- **No accounts, no sign-in, no cloud, no tracking.** This is a utility. Open it, use it, put it away.
