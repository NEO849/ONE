# ONE

![Swift](https://img.shields.io/badge/Swift-5.10-00bfa6?logo=swift&logoColor=black)
![SwiftUI](https://img.shields.io/badge/SwiftUI-5.0-00bfa6?logo=swift&logoColor=black)
![iOS](https://img.shields.io/badge/iOS-17%2B-00bfa6?logo=apple&logoColor=black)
![License](https://img.shields.io/badge/Lizenz-CC0_1.0-00bfa6?logo=open-source-initiative&logoColor=black)

> Visuell fortschrittliche SwiftUI-App zur Kommunikation mit Claude 3, ChatGPT, Mistral und Gemini – mit Timeline, Tagging, Blur und Glassmorphism.

---

## Screenshots

| SplashView                     | Timeline + Filter               | MiniMap                       |
|--------------------------------|----------------------------------|-------------------------------|
| ![Splash](media/one_splash.png) | ![Timeline](media/one_timeline.png) | ![MiniMap](media/one_minimap.png) |

---

## Funktionen

- Animierte SplashView mit Sound & Blur
- Kommunikation mit Claude 3 (Anthropic API)
- Lokale Verlaufs-Speicherung (`chat_history.json`)
- Glassmorphism-UI mit Tiefe, Schatten und Blur
- Farbige Tag-Markierungen: Wichtig, Idee, Bug, Notiz
- Timeline mit interaktiven Markern & Popover-Auswahl
- MiniMap mit Hover-Zoom & Scroll-to-Message
- Filterleiste zur gezielten Anzeige nach Label
- Modular nach MVVM + Services
- `#Preview` für alle Views mit Mock-Daten

---

## Projektdiagramm (Mermaid)

```mermaid
graph TD
    A[ONEApp.swift] --> B[SplashView]
    A --> C[MainView]

    C --> D[ONEViewModel]
    C --> E[ConversationTimelineView]
    C --> F[MiniMapProView]
    C --> G[FilterBarView]
    C --> H[ONECardMessage]
    C --> I[GlassCardInputField]

    D --> J[ONEAPIService]
    D --> K[ConversationStorageService]

    C --> L[ONETopBar]
    C --> M[TagPopoverView]

    subgraph Views
        B
        C
        E
        F
        G
        H
        I
        L
        M
    end

    subgraph ViewModel & Services
        D
        J
        K
    end
