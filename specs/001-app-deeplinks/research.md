# Research: App Store and Play Store Deep Linking

## Decision: Native App/Universal Links (Long-term Stability)

### Rationale
FDL is deprecated and scheduled for shutdown on August 25, 2025. Technical debt is avoided by using native App Links (Android) and Universal Links (iOS) from the start.

### Link Format Decision
- Base Domain: `links.holy.app`
- Format: `https://links.holy.app/share?v=bookId_chapter_verse`

### Key Technology
- `app_links` package for handling URI streams.

## Implementation Patterns

### Link Parsing Logic
Logic remains the same, but the listener changes to `AppLinks`.
