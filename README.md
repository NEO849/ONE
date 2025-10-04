<table>
<tr>
<td>
<img src="Docs/logo.jpg" width="100" />
<img src="Docs/onetext.png" width="100" />
</td>
<td>
<h1 style="color: #0096FF;"> – Multi-Agent KI Chat</h3>
</td>
</tr>
</table>

![Swift](https://img.shields.io/badge/Swift-5.10-0096FF?logo=swift&logoColor=black)
![SwiftUI](https://img.shields.io/badge/SwiftUI-%F0%9F%92%96-0096FF?logo=swift&logoColor=black)
![Xcode](https://img.shields.io/badge/Xcode-15%2B-0096FF?logo=xcode&logoColor=black)
![iOS](https://img.shields.io/badge/iOS-17%2B-0096FF?logo=apple&logoColor=black)
![macOS](https://img.shields.io/badge/macOS-14%2B-0096FF?logo=apple&logoColor=black)
![License](https://img.shields.io/badge/License-MIT-0096FF?logo=open-source-initiative&logoColor=black)

**Multi-Agent Orchestrierung für KI-Chats**  
_In „ONE“ teilt **Claude** die Nutzer-Eingabe intelligent auf **ChatGPT**, **Gemini** und **Mistral** auf, sammelt die Ergebnisse und fasst sie smart zusammen._  
**Architektur:** MVVM + Repository • **UI:** SwiftUI (NavigationStack, Z-Stacks, Glassmorphism) • **Datenfluss:** `@EnvironmentObject` als Source of Truth.

---

## ![Design / Screenshots](https://img.shields.io/badge/Design-%230096FF?style=for-the-badge&logo=none)

<div>
  <img src="Docs/agent1short.png" width="23%" />
  <img src="Docs/agent2short.png" width="15%" />
  <img src="Docs/agent3short.png" width="23%" />
  <img src="Docs/agent4short.png" width="15%" />
</div>

---

## ![Funktionen](https://img.shields.io/badge/Funktionen-%230096FF?style=for-the-badge&logo=none)

- **Multi-Agent Orchestrierung:** Claude verteilt Prompts an ChatGPT, Gemini, Mistral und fasst Antworten zusammen  
- **Seitliche Runden-Liste:** Alle Conversation-Rounds links in einer Leiste (NavigationStack)  
- **Agent-Cards im Z-Stack:** Leicht versetzt gestapelte Karten, jede Antwort einzeln antippbar  
- **Typensichere Agenten:** `enum AgentKind` (Claude, ChatGPT, Gemini, Mistral) inkl. Rollen & Hintergründe  
- **State-Management:** `@EnvironmentObject` als **Source of Truth** (oberste View), `@State` / `@Binding` für lokale UI-Zustände  
- **Repositories & Services:** Saubere Daten-Schicht mit Protokollen, Mock/Live-Implementierungen  
- **Sichere API-Keys:** via `.xcconfig` (keine Keys im Code – best practices)  
- **Theming:** Eigene AI-Hintergründe (z. B. in `Assets.xcassets/AiBackgroundCards`)  
- **MVVM strikt:** Klare Trennung von View, ViewModel, Model & Repository

---

### Hauptkomponenten

| Modul/Target | Technologie                  | Beschreibung                                   |
|--------------|------------------------------|------------------------------------------------|
| `ONE`        | SwiftUI + Combine            | App-UI, Navigation, Agent-Cards, Input/Output  |
| `Data`       | Protocol + Implementierungen | Repositories (z. B. `AnswerRepository`)        |
| `Domain`     | Reine Modelle & Use-Cases    | `Agent`, `AgentKind`, `ConversationRound`, …   |
| `Services`   | HTTP / SDK-Adapter           | OpenAI, Anthropic, Google, Mistral             |

---

### Kernkonzepte

- **MVVM-Architektur** mit `ConversationViewModel` als zentrale Schnittstelle zur UI  
- **Repository-Pattern** für austauschbare Datenquellen (Mock vs. Live)  
- **Property Wrappers:** `@State`, `@Binding`, `@Published`, `@EnvironmentObject`  
- **Lifecycle Hooks:** `willSet` / `didSet` an ausgewählten Properties (z. B. Input-Normalisierung)

---

## Architektur 🏛️ (Mermaid)

graph TD
  U[User Prompt] --> O[Claude Orchestrator]
  O --> A1[Agent: ChatGPT]
  O --> A2[Agent: Gemini]
  O --> A3[Agent: Mistral]
  A1 --> M[Merger (Claude)]
  A2 --> M
  A3 --> M
  M --> VM[ConversationViewModel]
  VM --> V[SwiftUI Views<br/>NavigationStack + ZStacks]
  
  subgraph Data Layer
    R[AnswerRepository Protocol]
    RL[LiveAnswerRepository]
    RM[MockAnswerRepository]
  end
