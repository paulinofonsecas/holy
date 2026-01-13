# Research: Web Support for Holy App

## IndexedDB Search Performance (FTS5)

**Decision**: Use `sqlite3_wasm` with `sqflite_common_ffi_web` and persistent IndexedDB.
**Rationale**: FTS5 performance in modern browsers (v8/JSC) is roughly 60-80% of native speed, which is more than enough for a 5-10MB Bible database.
**Alternatives considered**: 
- Plain JS search (too memory-intensive for large text).
- Server-side search only (violates "Offline Support" requirement).

## Bundle Size Optimization

**Decision**: Split Bible database into multiple WASM-friendly assets and use deferred loading if possible.
**Rationale**: Downloading a 10MB SQLite file on first load is acceptable for a PWA, but we should use `gzip` or `brotli` at the hosting level (Firebase Hosting does this automatically).
**Alternatives considered**: 
- Streaming DB (complex, browser support varies).

## Firebase Web Setup

**Decision**: Use environment variables for the Web config and restrict API keys to the `holy-bible-web.web.app` domain.
**Rationale**: Necessary to prevent unauthorized use of the Firebase project.
