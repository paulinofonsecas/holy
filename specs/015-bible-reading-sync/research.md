# research.md

Decisions & Rationale
---------------------

- Transport: Firebase Realtime Database (RTDB)
  - Rationale: native Flutter support, realtime subscriptions, offline sync, server timestamps, and security rules for authorization.

- Discovery: Hybrid (public by default; host can mark private)
  - Rationale: balances discoverability and privacy; simplifies onboarding while allowing private studies.

- Sync model: Hybrid host-lock with opt-out
  - Rationale: Enables guided readings while allowing participants control to stop following when needed.

Alternatives considered
-----------------------
- WebSocket / custom signaling server: more control but higher infra cost.
- Use meeting/chat infra: lighter integration but less consistent across meeting platforms.

Resolved Unknowns
-----------------
- Q1: Session controllers = Host + authorized guests
- Q2: Sync behavior = Hybrid host-lock default
- Q3: Transport = Firebase Realtime Database
