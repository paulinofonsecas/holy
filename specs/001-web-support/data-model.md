# Data Model: Web Support

## Entities

### `WebDatabaseStatus` (State)
- **Status**: enum { initializing, downloading, extracting, ready, error }
- **Progress**: double (0.0 to 1.0)
- **ErrorMessage**: String?

### `ResponsiveLayout` (UI)
- **DeviceType**: enum { mobile, tablet, desktop }
- **NavigationMode**: enum { bottomBar, drawer, sideRail }
- **ContentPadding**: double

## Requirements Mapping
- **FR-003**: Supported by `WebDatabaseStatus` tracking during initialization.
- **FR-004**: Supported by `ResponsiveLayout` logic based on `MediaQuery`.
