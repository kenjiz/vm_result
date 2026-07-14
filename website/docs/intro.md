---
sidebar_position: 1
---

# Introduction

`vm_result` is a minimal, production-grade MVVM (Model-View-ViewModel) state management library for Flutter. It is designed to completely eliminate the repetitive boilerplate associated with managing asynchronous operations (such as loading, data, and error lifecycles).

By combining Flutter's native `ChangeNotifier` and `ValueListenable` with robust functional `Result<T>` state encapsulation, `vm_result` provides a lightweight, performant, and beginner-friendly alternative to heavy state management frameworks.

---

## Why vm_result?

When developing feature screens in Flutter, you frequently fetch data from an API, database, or WebSocket. Typically, this requires you to write code to:
1. Show a loading indicator.
2. Execute the async operation.
3. Catch and log exceptions, showing an error card with a retry option.
4. Render the successful data on the screen.
5. Prevent duplicate concurrent requests (deduplication).

In most frameworks, you have to write sealed classes, yield/emit state transitions, or build complex providers for every single screen. **`vm_result` automates all of this through simple, safe async guard methods.**

---

## Core Features

- **Sealed State Encapsulation:** A `Result<T>` sealed class that guarantees you can never forget to handle loading or error states.
- **Built-in Async Guards:** Methods like `run()`, `runOptimistic()`, `runLatest()`, and `runStream()` that handle state transitions, try-catch blocks, and warning logs automatically.
- **Automatic Deduplication:** Guards drop concurrent duplicate inputs by default, keeping your API endpoints safe from accidental double-taps.
- **Cancel-and-Replace Semantics:** `runLatest()` provides search-as-you-type support out-of-the-box, automatically discarding stale responses.
- **One-Shot UI Effects:** `VMResultEffect` and `EffectListener` let you handle transient UI side-effects (like showing snackbars or navigation) cleanly.
- **Pluggable Logging:** Fully customizable logger support (`VMResultLogger`) allowing you to redirect package logs to your favorite logging framework (e.g. Talker).

---

## Comparison with other State Management Solutions

Here is how `vm_result` compares conceptually with other popular Flutter state management libraries:

| Dimension | `vm_result` | BLoC / Cubit | Riverpod |
| :--- | :--- | :--- | :--- |
| **Boilerplate** | 🟢 **Extremely Low**<br/>(Guards handle lifecycle automatically) | 🔴 **High**<br/>(Must declare Events, States, and map transitions) | 🟡 **Moderate**<br/>(Uses code generation and custom providers) |
| **Learning Curve** | 🟢 **Minimal**<br/>(Uses standard, native `ChangeNotifier` concepts) | 🔴 **Steep**<br/>(Requires understanding streams and event loops) | 🟡 **Moderate**<br/>(Requires learning `WidgetRef` and provider graph APIs) |
| **Async State Handling** | 🟢 **Built-in**<br/>(Standardized `Result<T>` lifecycle) | 🔴 **Manual**<br/>(Must define separate Loading/Error states manually) | 🟢 **Built-in**<br/>(Uses built-in `AsyncValue` class) |
| **Deduplication / debounce** | 🟢 **Out-of-the-box**<br/>(Guards drop duplicate calls naturally) | 🟡 **Manual / Custom**<br/>(Requires writing custom EventTransformers) | 🟡 **Manual / Custom**<br/>(Requires custom debounce debounce helpers) |
| **Best Used For** | UI/API screens, standard CRUD features, and robust MVVM architectures | Large teams, complex event streams, and strict state auditing | Highly nested dependency graphs and global reactive state sharing |

---

## Next Steps

Get started with `vm_result` by checking out:
- [Getting Started](./getting-started.md)
- [Result and ValueResult](./core-concepts/result-types.md)
- [Beginner's Tutorial](./tutorials/beginner-tutorial.md)
