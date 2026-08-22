## Offline-First Task Board (iOS)

A robust, offline-first task management iOS application built with Swift and SwiftUI.
This project demonstrates a platform-grade approach to handling complex state management, data persistence, and network synchronization without blocking the user interface.

## Architecture & Technical Decisions

I approached this with a focus on platform-grade reliability and strict separation of concerns, utilizing native Apple frameworks wherever possible.

- UI & State Management (SwiftUI + MVVM): Given the strict assignment timeline and the assumption that the app must natively support both iPhone and iPad, SwiftUI was the most pragmatic choice. Its declarative, state-driven paradigm significantly accelerated development across the Apple ecosystem.
  I paired this with an MVVM architecture, utilizing ViewModels to ensure a strict, clean separation between the UI components and the underlying business logic.

- Offline-First Sync (The Outbox Pattern): The app completely decouples the UI layer from the network. User actions (Create, Update, Delete) are saved to local storage alongside an atomic mutation record in a pending Outbox queue.
  The UI updates instantly, and a background SyncEngine drains the queue sequentially when the network returns.

- Outbox Compaction (Debouncing): To minimize network overhead, the data layer squashes redundant actions.
Moving a single card 20 times while offline results in only one pending update mutation being queued for the server.

- Persistence (Core Data): Selected over newer abstractions like SwiftData and third-party SQLite wrappers like GRDB. While SwiftData is modern, Core Data offers battle-tested stability and the fine-grained thread management (via explicit perform blocks) critical for safely orchestrating background Outbox mutations.
I chose it over GRDB specifically to avoid introducing third-party dependencies, demonstrating that this complex offline architecture can be built reliably using strictly first-party Apple frameworks.

- Concurrency (Swift 6 async/await): Used in place of Combine to maintain strict, linear control flow for database and network operations.
It prevents closure nesting and leverages the compiler’s data-race safety.

- Network State (NWPathMonitor): Apple’s native Network framework handles connectivity observation.
It is highly battery-efficient and allows the app to passively wake the SyncEngine the millisecond an interface becomes available.

- Network Session Profiles: The NetworkService is designed around configurable URLSession profiles rather than a shared singleton.
  This allows the background synchronization traffic to utilize specific caching policies, timeout intervals, and background-thread priorities without interfering with
  any future foreground user data requests.

## Assumptions 

- Universal Target: The UI components were explicitly built to scale across both iOS and iPadOS.

- Upstream Authentication: Assuming this is a module within a larger product,
  I assumed user sessions/auth are handled upstream, and the NetworkService will eventually inject a globally stored token into its requests.

- Backend Audit Trails: The Outbox queues explicit chronological verbs (e.g., create, then update) rather than just the final object state,
  assuming the remote service requires an accurate audit trail of events.

## Known Limitations
- App Uninstalls: Because the app is offline-first, if a user creates data offline and deletes the app before the SyncEngine connects to the network, that unsynced data is permanently lost.

- Mock Network: As a live remote service was not provided, the NetworkService utilizes an asynchronous delay to simulate HTTP responses, allowing the Outbox queue to drain for demonstration purposes.

## Future Improvements
- Conflict Resolution: Implementing a Server-Authoritative or Last-Write-Wins (LWW) strategy with vector clocks to handle edge cases where a task is modified on two separate devices simultaneously.

- Background Fetch: Utilizing BGTaskScheduler to process the Outbox queue silently in the background while the app is suspended.

- Pagination: Adding Core Data fetch limits and lazy loading to keep the memory footprint strictly bounded if the board scales to thousands of tasks.

## AI Tools Used
I used Gemini during this project as a pair-programming assistant. My goal was to leverage AI to accelerate delivery while retaining complete ownership of the system architecture.

- Architectural Validation: I used it as a sounding board to validate the Outbox pattern against other offline-first strategies.

- API Edge-Cases: I utilized it to help debug a specific SwiftUI DropDelegate view-destruction loop (a common framework quirk) during the cross-column drag-and-drop implementation.

- Boilerplate: I used it to generate the standard Core Data Stack configuration, allowing me to focus my time entirely on the domain logic and sync engine.

## Approximate Time Spent: ~9 hours

- Architecture & Persistence Setup: 2 hours

- UI & Drag-and-Drop Implementation: 3.5 hours

- Offline Sync Engine & Compaction: 2.5 hours

- Testing, Polish & Documentation: 1 hour



  
