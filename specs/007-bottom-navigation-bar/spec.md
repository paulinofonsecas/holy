# Feature 007: Bottom Navigation Bar

## Context
As defined in the Project Constitution (Principle VI), the application must provide a consistent navigation experience. A Bottom Navigation Bar is the standard for mobile applications to allow quick access to top-level destinations.

## Requirements
1. **Destinations**: The bar must include three main sections:
   - **Bíblia (Reading)**: Access to the scripture reading view.
   - **Pesquisa (Search)**: Access to the verse search feature.
   - **Perfil (Profile)**: Access to user settings and profile.
2. **Visual Consistency**: Must follow the app's theme (colors and icons).
3. **State Persistence**: Switching between tabs should preserve the state of each view (e.g., scroll position in the Bible, search results in Search).
4. **Active State**: The current active tab must be clearly highlighted.

## User Stories
- **As a user**, I want to switch between reading the Bible and searching for verses with a single tap.
- **As a user**, I want my search results to remain visible when I briefly switch to my profile and back.

## Acceptance Criteria
- [X] Bottom Navigation Bar is visible on all main screens.
- [X] Tapping "Bíblia" navigates to the reading screen.
- [X] Tapping "Pesquisa" navigates to the search screen.
- [X] Tapping "Perfil" navigates to the profile screen.
- [X] The active tab is visually distinct.
- [X] Navigation state is preserved across tab switches.
