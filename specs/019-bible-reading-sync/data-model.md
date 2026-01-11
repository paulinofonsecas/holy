# data-model.md

Entities
--------

- StudyRoom
  - `room_id` (string)
  - `title` (string)
  - `host_id` (string)
  - `is_public` (bool)
  - `participants` (map participantId -> metadata)
  - `metadata` (object: description, authorized_controllers[])

- Session
  - `session_id` (string)
  - `room_id` (string)
  - `started_at` (timestamp)
  - `state` (last_applied_event_id, current_verseRef)

- VerseReference
  - `book` (string)
  - `chapter` (int)
  - `verse` (int)
  - `version` (string, optional)

- ShareEvent
  - `event_id` (string)
  - `session_id` (string)
  - `type` (enum: ShareVerse, Advance, Join, Leave)
  - `verseRef` (VerseReference)
  - `author_id` (string)
  - `created_at` (server timestamp)

- SyncState
  - `participant_id` (string)
  - `last_applied_event_id` (string)
  - `status` (enum: following, detached)

Validation rules
- `authorized_controllers` must include `host_id` initially.
- `ShareEvent.verseRef` must have `book`, `chapter`, `verse`.
