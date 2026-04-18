# ONE – Parallel AI Chat for iOS

> Ask once. Hear four perspectives.

**ONE** is a native iOS app built with SwiftUI that sends every user prompt simultaneously to four leading AI models — Gemini, Claude, Mistral, and ChatGPT — and displays all responses side by side. A final ChatGPT pass synthesises and fact-checks the three answers before delivering a unified verdict.

---

## Screenshots

| Grid View | Stacked View | Onboarding | History |
|:---------:|:------------:|:----------:|:-------:|
| *coming soon* | *coming soon* | *coming soon* | *coming soon* |

> **Note for reviewers:** Screenshots will be added after TestFlight distribution. All UI is production-ready and previews compile without errors.

---

## Features

### Core Experience
- **Parallel AI calls** — Gemini, Claude, Mistral answer simultaneously via `async let` / `withTaskGroup`; ChatGPT synthesises the result
- **Progressive card updates** — each agent card fills in as its response arrives, not when all three are done
- **Two layout modes** — switch between a 2×2 grid (equal-size cards) and a tappable stacked deck
- **Full-answer sheet** — tap “Mehr anzeigen” to read the complete response; one-tap copy to clipboard

### Infrastructure
- **Secure API key storage** — all four keys stored in iOS Keychain via `SecureKeyManager`; never in UserDefaults or source code
- **First-launch onboarding** — guided key entry before anything is sent to a real API
- **In-app settings** — edit keys at any time via the gear icon → service hot-swaps without restart
- **Conversation history** — all rounds persisted as JSON in UserDefaults; survive app restarts
- **Swipe-to-delete** in sidebar history

### UX Polish
- **Skeleton shimmer** while agents are responding (pulsing opacity animation)
- **Error card** with orange stroke + icon when an API call fails (no crash, readable message)
- **Welcome screen** on first open or after “New Chat”
- **Dark Mode** throughout; glass morphism design system (`GlassCardModifier`, `GlassLightSweepModifier`, `GlassTiltModifier`)
- **Auto-scroll** to latest message; keyboard-aware input bar via `safeAreaInset`

---

## Architecture

Strict **MVVM** with Dependency Injection via protocol. No business logic in views.

```
View layer            ViewModel layer         Service / Data layer
────────────          ─────────────────     ────────────────────
ContentView           ConversationViewModel   ConversationProtocol
  ├ TopBarView          @MainActor               ├ RealConversationService
  ├ ChatMessageListView @Published var rounds      │   ├ GeminiAPIClient
  │   ├ GridAgentCardsView               │   ├ ClaudeAPIClient
  │   └ StackedAgentCardsView            │   ├ MistralAPIClient
  ├ GlassCardInputField               │   └ ChatGPTAPIClient
  └ HistorySidebarView               └ MockConversationService

Models (Value Types / Codable)
  ConversationRound → [ChatStep] → [AgentType: String] + finalReply

Managers
  SecureKeyManager   – Keychain read/write
  PersistenceManager – UserDefaults JSON encode/decode
```

### Key Design Decisions

| Decision | Rationale |
|---|---|
| `ConversationProtocol` DI | `RealConversationService` and `MockConversationService` are interchangeable without touching the ViewModel |
| `withTaskGroup` for parallel calls | Progressive UI: each card updates the moment its agent responds |
| `@MainActor` ViewModel | All `@Published` mutations on main thread; no `DispatchQueue.main.async` noise |
| Value types (`struct`) for models | Thread-safe by default; copy semantics prevent race conditions in async context |
| `safeAgentReply` helper | Network errors become readable strings — the app never crashes on API failure |
| `CodingKeyRepresentable` on `AgentType` | Allows `[AgentType: String]` to round-trip through `JSONEncoder` as a JSON object |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Concurrency | Swift Structured Concurrency (`async/await`, `withTaskGroup`) |
| Persistence | `UserDefaults` (JSON) + iOS Keychain (`Security` framework) |
| Networking | `URLSession` with `async/throws` wrappers |
| APIs | Google Gemini 1.5 Flash · Anthropic Claude 3.5 Haiku · Mistral Small · OpenAI GPT-4o mini |
| Min. Deployment | iOS 17.0 |

---

## Getting Started

### Prerequisites
- Xcode 15.2+
- iOS 17+ device or simulator
- API keys for all four providers (free tiers available)

### API Key Registration

| Provider | Link | Free Tier |
|---|---|---|
| **Gemini** | [Google AI Studio](https://aistudio.google.com/apikey) | Yes |
| **Claude** | [Anthropic Console](https://console.anthropic.com/) | Pay-as-you-go |
| **Mistral** | [Mistral Platform](https://console.mistral.ai/) | Yes |
| **ChatGPT** | [OpenAI Platform](https://platform.openai.com/api-keys) | Pay-as-you-go |

### Installation

```bash
git clone https://github.com/NEO849/ONE.git
cd ONE
open ONE.xcodeproj
```

1. Select your team in **Signing & Capabilities**
2. Build & Run on device or simulator (iOS 17+)
3. On first launch the **Onboarding** screen asks for your four API keys
4. Keys are stored in the iOS Keychain — never in iCloud or local files

> **Keys missing?** Tap the **gear icon** (⚙️) in the top bar at any time to edit them.

---

## Project Structure

```
ONE/
├── ONEApp.swift                          App entry point; selects Real vs Mock service
├── Data/
│   ├── Manager/
│   │   ├── SecureKeyManager.swift        Keychain wrapper (save / load / delete)
│   │   └── PersistenceManager.swift      UserDefaults JSON persistence
│   ├── Model/
│   │   ├── AgentType.swift               Enum: gemini | claude | mistral | chatgpt
│   │   ├── ChatStep.swift                One user prompt + agent responses
│   │   ├── ConversationsRound.swift      A conversation session (list of steps)
│   │   ├── LayoutMode.swift              Enum: grid | stacked
│   │   └── ONEAPIError.swift             Typed error enum for all 4 APIs
│   └── Service/
│       ├── ConversationProtocol.swift    DI interface (plan → fetch → finalise)
│       ├── MockConversationService.swift Fake service with realistic delays
│       └── Real/
│           ├── GeminiAPIClient.swift
│           ├── ClaudeAPIClient.swift
│           ├── MistralAPIClient.swift
│           ├── ChatGPTAPIClient.swift
│           └── RealConversationService.swift Orchestrates all 4 clients
├── UI/
│   ├── Components/
│   │   ├── AgentCardView.swift           Card: loading shimmer | error state | answer
│   │   ├── GridAgentCardsView.swift      2×2 equal-size grid layout
│   │   ├── StackedAgentCardsView.swift   Tappable offset deck layout
│   │   ├── HistorySidebarView.swift      Slide-in history with swipe-to-delete
│   │   ├── UserPromptBubbleView.swift
│   │   └── Subviews/
│   │       ├── FullAnswerAgentSheet.swift  Full text + copy-to-clipboard
│   │       └── LeftAgentNameRailView.swift
│   ├── Styles/
│   │   ├── AgentTheme.swift
│   │   ├── GlassStyles.swift             .glassCard() ViewModifier
│   │   ├── GlassLightSweepModifier.swift
│   │   ├── GlassTiltModifier.swift
│   │   ├── GlassWowCardModifier.swift
│   │   ├── DismissKeyboardOnTapModifier.swift
│   │   └── KeyboardObserver.swift
│   └── Views/
│       ├── ContentView.swift             Main screen; wires all components
│       ├── ChatMessageListView.swift     Scroll list + welcome empty state
│       ├── GlassCardInputField.swift
│       ├── OnboardingView.swift          First-launch key setup
│       ├── SettingsView.swift            Edit keys post-setup
│       └── TopBarView.swift              Logo | layout toggle | settings | new chat
└── ViewModel/
    └── ConversationViewModel.swift   @MainActor source of truth
```

---

## Coding Standards

- No business logic in Views — Views are pure rendering
- No force-unwraps (`!`) anywhere in production code
- All identifier names ≥ 4 characters (except `id`)
- German inline comments explaining *why*, not *what*
- `#Preview` macro in every View file
- Errors are always caught and surfaced as readable UI — never silently ignored

---

## Roadmap

- [ ] **Streaming responses** — token-by-token display as agents respond
- [ ] **iPad / Landscape** layout optimisation
- [ ] **Accessibility** — VoiceOver labels on all interactive elements
- [ ] **Unit tests** for ViewModel and API clients
- [ ] **App Icon** + Launch Screen assets
- [ ] **TestFlight** distribution

---

## License

MIT © 2025–2026 Michael Fleps
