<div align="center">

<img src="https://raw.githubusercontent.com/NEO849/ONE/main/logo.jpg" alt="ONE App Logo" width="140" style="border-radius: 22px;"/>

# ONE — Parallel AI Chat for iOS

**Ask once. Hear four minds.**

[![Swift](https://img.shields.io/badge/Swift-5.9-F05138?style=flat-square&logo=swift&logoColor=white)](https://swift.org)
[![iOS](https://img.shields.io/badge/iOS-17%2B-000000?style=flat-square&logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-5-0071E3?style=flat-square&logo=swift&logoColor=white)](https://developer.apple.com/xcode/swiftui/)
[![Xcode](https://img.shields.io/badge/Xcode-15.2%2B-147EFB?style=flat-square&logo=xcode&logoColor=white)](https://developer.apple.com/xcode/)
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen?style=flat-square)](LICENSE)
[![Platforms](https://img.shields.io/badge/Platforms-iPhone%20%7C%20iPad-8E44AD?style=flat-square&logo=apple)]()

<img src="https://raw.githubusercontent.com/NEO849/ONE/main/onetext.png" alt="ONE" width="220"/>

> ONE sends your prompt simultaneously to **Gemini**, **Claude**, **Mistral** and **ChatGPT** —  
> streams every token live — then lets ChatGPT synthesise all three answers into one verdict.

</div>

---

## What Is ONE?

ONE is a native **SwiftUI** app for iOS that eliminates the "which AI should I ask?" dilemma by asking all four at once. Every response streams token-by-token in real time via **Server-Sent Events (SSE)**. A built-in 3-stage orchestration pipeline plans, parallelises, and synthesises — so you get breadth *and* depth in a single tap.

---

## Feature Showcase

### Core Experience

| Feature | Detail |
|---|---|
| **4 Agents in Parallel** | Gemini 1.5 Flash · Claude 3.5 Haiku · Mistral Small · GPT-4o Mini |
| **Token-for-Token Streaming** | SSE (`URLSession` byte-stream) for all 4 APIs simultaneously |
| **3-Stage Orchestration** | Plan → Parallel fetch → Final ChatGPT synthesis & fact-check |
| **2 Layout Modes** | 2×2 Grid ↔ Stacked deck, animated toggle |
| **Skeleton Shimmer** | Pulsing placeholder animation while agents respond |
| **Error Cards** | Orange stroke + readable message — zero crashes on API failure |
| **Full-Answer Sheet** | Tap any card → full text, one-tap Copy to Clipboard |
| **History Sidebar** | All conversations persisted as JSON; Swipe-to-Delete |
| **Onboarding Flow** | Guided API-key setup on first launch |
| **In-App Settings** | Edit keys at any time via ⚙️ — hot-swap without restart |

### Security & Privacy

| Feature | Detail |
|---|---|
| **Keychain Storage** | All 4 API keys stored in iOS Keychain via `SecureKeyManager` |
| **Git-Safe Config** | `Secrets.local.xcconfig` is gitignored; template committed instead |
| **DEBUG Key Injector** | `DeveloperKeyInjector` injects keys only in `#if DEBUG` builds |
| **No Telemetry** | Zero analytics, zero tracking — your prompts stay on-device |

### Polish

- **Dark Mode** throughout — glass morphism design system
- **VoiceOver Accessibility** — all interactive elements labelled
- **Auto-scroll** to latest message
- **Keyboard-aware** input bar via `safeAreaInset`
- **Welcome screen** on fresh start or "New Chat"

---

## Architecture

Strict **MVVM** with Dependency Injection via protocol. Zero business logic in Views.

```
┌─────────────────────────────────────────────────────────────────┐
│                         View Layer                              │
│  ContentView                                                    │
│  ├── TopBarView          (logo | layout toggle | ⚙️ | new chat) │
│  ├── ChatMessageListView (scroll list + welcome state)          │
│  │   ├── UserPromptBubbleView                                   │
│  │   ├── GridAgentCardsView      ← 2×2 grid layout             │
│  │   └── StackedAgentCardsView   ← tappable deck layout        │
│  │       └── AgentCardView  (shimmer | error | streaming text)  │
│  │           └── FullAnswerAgentSheet  (full text + copy)       │
│  ├── GlassCardInputField                                        │
│  └── HistorySidebarView          (swipe-to-delete)             │
└────────────────────┬────────────────────────────────────────────┘
                     │ @Published / @ObservedObject
┌────────────────────▼────────────────────────────────────────────┐
│                     ViewModel Layer                             │
│  ConversationViewModel   @MainActor                             │
│  ├── orchestrate(prompt:)  → plan → parallel → synthesise       │
│  ├── @Published var rounds: [ConversationRound]                 │
│  └── @Published var layoutMode: LayoutMode                      │
└────────────────────┬────────────────────────────────────────────┘
                     │ ConversationProtocol (DI)
          ┌──────────┴───────────┐
          ▼                      ▼
   RealConversationService   MockConversationService
   ├── GeminiAPIClient           (realistic delays,
   ├── ClaudeAPIClient            no real keys needed)
   ├── MistralAPIClient
   └── ChatGPTAPIClient

┌─────────────────────────────────────────────────────────────────┐
│                       Data Layer                                │
│  Models (Codable value types)                                   │
│  ConversationRound → [ChatStep] → [AgentType: String]           │
│                                                                 │
│  Managers                                                       │
│  SecureKeyManager    – Keychain read / write / delete           │
│  PersistenceManager  – UserDefaults JSON encode / decode        │
└─────────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

| Decision | Rationale |
|---|---|
| `ConversationProtocol` DI | `RealConversationService` & `MockConversationService` swap without touching ViewModel |
| `withTaskGroup` for parallel calls | Progressive UI: each card fills the moment *its* agent responds |
| `@MainActor` ViewModel | All `@Published` mutations on main thread — no `DispatchQueue` noise |
| Value types (`struct`) for models | Thread-safe by default; copy semantics prevent async race conditions |
| `CodingKeyRepresentable` on `AgentType` | `[AgentType: String]` round-trips through `JSONEncoder` as a JSON object |
| `safeAgentReply` helper | Network errors become readable strings — the app never crashes on API failure |

---

## How Streaming Works

```swift
// ConversationProtocol.swift
protocol ConversationProtocol {
    /// Phase 1: optional planning step
    func planStep(for prompt: String) async throws -> String

    /// Phase 2: fetch agent stream — yields tokens as they arrive
    func fetchAgentStream(
        agent: AgentType,
        prompt: String,
        plan: String
    ) -> AsyncThrowingStream<String, Error>

    /// Phase 3: final ChatGPT synthesis of all three answers
    func makeFinalStream(
        prompt: String,
        agentAnswers: [AgentType: String]
    ) -> AsyncThrowingStream<String, Error>
}
```

Each `AsyncThrowingStream` maps directly to a live SSE connection. The ViewModel consumes all four streams concurrently via `withTaskGroup`, publishing token deltas to `@Published` properties that drive the UI:

```swift
// ConversationViewModel.swift  (simplified)
await withTaskGroup(of: Void.self) { group in
    for agent in AgentType.parallelAgents {
        group.addTask {
            for try await token in service.fetchAgentStream(agent: agent, prompt: prompt, plan: plan) {
                await MainActor.run { self.appendToken(token, for: agent) }
            }
        }
    }
}
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Concurrency | Swift Structured Concurrency (`async/await`, `withTaskGroup`, `AsyncThrowingStream`) |
| Streaming | Server-Sent Events (SSE) over `URLSession` byte-stream |
| Persistence | `UserDefaults` (JSON) + iOS Keychain (`Security` framework) |
| Networking | `URLSession` with `async/throws` wrappers |
| AI APIs | Google Gemini 1.5 Flash · Anthropic Claude 3.5 Haiku · Mistral Small · OpenAI GPT-4o Mini |
| Min. Deployment | iOS 17.0 |
| Toolchain | Xcode 15.2+ |

---

## Getting Started

### Prerequisites

- Xcode 15.2 or newer
- iOS 17+ device or simulator
- API keys for at least one provider (free tiers available for Gemini and Mistral)

### API Key Registration

| Provider | Console | Free Tier |
|---|---|---|
| **Gemini** | [Google AI Studio](https://aistudio.google.com/apikey) | Yes — generous quota |
| **Claude** | [Anthropic Console](https://console.anthropic.com/) | Pay-as-you-go |
| **Mistral** | [Mistral AI Platform](https://console.mistral.ai/) | Yes — free tier |
| **ChatGPT** | [OpenAI Platform](https://platform.openai.com/api-keys) | Pay-as-you-go |

### Installation

```bash
git clone https://github.com/NEO849/ONE.git
cd ONE
open ONE.xcodeproj
```

1. Select your **Team** under *Signing & Capabilities*
2. Build & Run on device or simulator (iOS 17+)
3. The **Onboarding** screen guides you through entering your four API keys
4. Keys are stored securely in the iOS Keychain — never in iCloud or source files

> **Need to update keys later?** Tap **⚙️** in the top bar at any time.

### Developer Setup (Optional — for key injection in DEBUG builds)

```bash
# Copy the secrets template
cp ONE/Configuration/Secrets.xcconfig.template ONE/Configuration/Secrets.local.xcconfig

# Or use the provided setup script
bash scripts/setup-secrets.sh
```

Then open `Secrets.local.xcconfig` and fill in your keys. The file is gitignored by default. In DEBUG builds, `DeveloperKeyInjector.swift` reads these values and pre-populates the Keychain so you skip the Onboarding screen.

```swift
// DeveloperKeyInjector.swift  (DEBUG only)
#if DEBUG
struct DeveloperKeyInjector {
    static func injectIfNeeded() {
        // Reads from Secrets.local.xcconfig via Bundle infoPlist entries
        // and writes to Keychain via SecureKeyManager
        // Never compiled into Release builds
    }
}
#endif
```

---

## Project Structure

```
ONE/
├── ONEApp.swift                           App entry — wires Real vs Mock service
├── Data/
│   ├── Manager/
│   │   ├── SecureKeyManager.swift         Keychain wrapper (save/load/delete)
│   │   └── PersistenceManager.swift       UserDefaults JSON persistence
│   ├── Model/
│   │   ├── AgentType.swift                Enum: gemini | claude | mistral | chatgpt
│   │   ├── ChatStep.swift                 One prompt + all agent responses
│   │   ├── ConversationRound.swift        A full conversation session
│   │   ├── LayoutMode.swift               Enum: grid | stacked
│   │   └── ONEAPIError.swift              Typed errors for all 4 APIs
│   └── Service/
│       ├── ConversationProtocol.swift     DI interface (plan → fetch → finalise)
│       ├── MockConversationService.swift  Fake service with realistic delays
│       └── Real/
│           ├── GeminiAPIClient.swift      SSE streaming via Gemini API
│           ├── ClaudeAPIClient.swift      SSE streaming via Anthropic API
│           ├── MistralAPIClient.swift     SSE streaming via Mistral API
│           ├── ChatGPTAPIClient.swift     SSE streaming via OpenAI API
│           └── RealConversationService.swift  Orchestrates all 4 clients
├── UI/
│   ├── Components/
│   │   ├── AgentCardView.swift            Shimmer | error | streaming text card
│   │   ├── GridAgentCardsView.swift       2×2 equal-size grid
│   │   ├── StackedAgentCardsView.swift    Tappable offset deck
│   │   ├── HistorySidebarView.swift       Slide-in sidebar, swipe-to-delete
│   │   ├── UserPromptBubbleView.swift
│   │   └── Subviews/
│   │       ├── FullAnswerAgentSheet.swift  Full text + copy-to-clipboard
│   │       └── LeftAgentNameRailView.swift
│   ├── Styles/
│   │   ├── AgentTheme.swift               Per-agent colours & gradients
│   │   ├── GlassStyles.swift              .glassCard() ViewModifier
│   │   ├── GlassLightSweepModifier.swift
│   │   ├── GlassTiltModifier.swift
│   │   ├── GlassWowCardModifier.swift
│   │   └── KeyboardObserver.swift
│   └── Views/
│       ├── ContentView.swift              Main screen — wires all components
│       ├── ChatMessageListView.swift      Scroll list + welcome empty state
│       ├── GlassCardInputField.swift      Keyboard-aware glass input bar
│       ├── OnboardingView.swift           First-launch key setup
│       ├── SettingsView.swift             Edit keys post-setup
│       └── TopBarView.swift               Logo | toggle | settings | new chat
├── Debug/
│   └── DeveloperKeyInjector.swift        DEBUG-only key bootstrapping
├── Configuration/
│   └── Secrets.xcconfig.template         Committed template (no real keys)
└── ViewModel/
    └── ConversationViewModel.swift        @MainActor source of truth
```

---

## Coding Standards

- No business logic in Views — Views are pure rendering
- No force-unwraps (`!`) in production code
- `#Preview` macro in every View file
- Errors are always surfaced as readable UI — never silently ignored
- German inline comments explaining *why*, not *what*
- All identifier names ≥ 4 characters (except `id`)

---

## Roadmap

| Status | Feature |
|---|---|
| ✅ Done | Token-for-Token SSE streaming across all 4 APIs |
| ✅ Done | 3-stage orchestration (Plan → Parallel → Synthesise) |
| ✅ Done | 2 layout modes with animated toggle |
| ✅ Done | Skeleton shimmer & error cards |
| ✅ Done | Keychain security via `SecureKeyManager` |
| ✅ Done | Onboarding + Settings flow |
| ✅ Done | Conversation history with persistence |
| ✅ Done | VoiceOver Accessibility |
| ✅ Done | Dark Mode + Glass design system |
| 🔄 In Progress | iPad & Landscape layout optimisation |
| 📋 Planned | Unit tests for ViewModel and API clients |
| 📋 Planned | Widget Extension — latest summary on Home Screen |
| 📋 Planned | Custom agent selection (add/remove providers) |
| 📋 Planned | Prompt templates & favourites |
| 📋 Planned | TestFlight distribution |
| 💡 Idea | macOS (Catalyst) support |
| 💡 Idea | Local LLM support (Ollama) |

---

## Contributing

Contributions, bug reports, and feature requests are welcome!

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature`
3. Commit your changes following the existing coding standards
4. Open a Pull Request with a clear description

For larger changes, please open an issue first to discuss the approach.

---

## License

```
MIT License

Copyright (c) 2025–2026 Michael Fleps

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND.
```

---

<div align="center">

Built with SwiftUI · Powered by Gemini, Claude, Mistral & ChatGPT

<sub>© 2025–2026 Michael Fleps — MIT License</sub>

</div>
