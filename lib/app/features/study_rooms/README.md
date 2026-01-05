# Study Rooms Feature

This feature implements real-time Bible reading synchronization between participants.

## Structure

- `lib/app/features/study_rooms/`
  - `study_rooms_list.dart`: Screen to discover and join rooms.
  - `study_room_view.dart`: Main reading screen with sync controls.
  - `widgets/`: Reusable components like `FollowHostToggle`.
  - `room_settings.dart`: Host-only settings for the room.

## Routes

- `/study-rooms`: List of available rooms.
- `/study-room/:id`: Active study room session.
