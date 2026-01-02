# Data Model: Navigation

## Entities

### NavigationState
Represents the current state of the top-level navigation.

| Field | Type | Description |
|-------|------|-------------|
| `currentIndex` | `int` | The index of the currently active tab (0: Biblia, 1: Search, 2: Profile). |

## State Transitions

| Action | From | To | Condition |
|--------|------|----|-----------|
| `Tap Biblia` | Any | 0 | User taps the first item in the bottom bar. |
| `Tap Search` | Any | 1 | User taps the second item in the bottom bar. |
| `Tap Profile` | Any | 2 | User taps the third item in the bottom bar. |

## Validation Rules
- `currentIndex` must be between 0 and 2 (inclusive).
