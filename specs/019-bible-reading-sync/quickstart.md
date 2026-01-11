# Quickstart — Sincronização de leitura da Bíblia

Prerequisites
- Firebase project with Realtime Database enabled
- Flutter dev environment (see repo README)

Steps
1. Add Firebase config to app (use `firebase_options.dart` pattern already in repo).
2. Enable RTDB and add security rules for `studyRooms` per `contracts/rtdb-schema.json`.
3. Implement `StudyRoomService` using `firebase_database` Flutter plugin:
   - subscribe to `/studyRooms/{roomId}/events`
   - write events to `/studyRooms/{roomId}/events/{eventId}` with server timestamps
   - update presence at `/presence/{roomId}/{participantId}` using `onDisconnect()`
4. Add UI screens: `StudyRoomsList`, `StudyRoomView`, `FollowHostToggle`.
5. Run app and create a StudyRoom; invite a secondary device to join and verify events apply within 2s.

Testing
- Simulate network latency using Android emulator network throttling; measure event-to-render latency.
