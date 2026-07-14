# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-07-14

### Added
- Added pluggable logging contract `VMResultLogger` and `VMResultLogging` registry to support custom logging framework integrations.
- Added a web-safe `DefaultVMResultLogger` utilizing standard `dart:developer` logging.

### Changed
- Decoupled `talker_flutter` dependency from the package dependencies list.

### Fixed
- Fixed reactivity and state desync bug in `isExecuting` where UI listeners missed execution lifecycle transitions.
- Fixed memory leaks and missed updates in `EffectListener` by implementing `didUpdateWidget` for proper subscription syncing.
- Fixed a concurrency list-corruption race condition in `VMPaginated.loadMore` when state refreshes during pagination fetches.
- Fixed log noise by preventing error warning prints during normal VM disposals with in-flight operations.
- Fixed shadowed `_disposed` field on `VMResultEffect` class.
- Fixed typographical copy-paste errors in `ValueResult` documentation comments.

## [0.0.2] - 2026-07-14

### Changed
- Bumped Dart SDK version to `^3.12.0`.

## [0.0.1] - 2026-03-21

### Added
- Initial Release of `vm_result` core MVVM contracts, widgets, pagination, stream subscriptions, and helper guards.

[Unreleased]: https://github.com/kenjiz/vm_result/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/kenjiz/vm_result/compare/v0.0.2...v0.1.0
[0.0.2]: https://github.com/kenjiz/vm_result/compare/v0.0.1...v0.0.2
[0.0.1]: https://github.com/kenjiz/vm_result/releases/tag/v0.0.1
