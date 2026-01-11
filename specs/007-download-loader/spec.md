# Specification: Download Loader

## User Story
As a user, I want to see a loading indicator while a Bible version is being downloaded, so that I know the application is working and not frozen.

## Acceptance Criteria
- [ ] When a Bible version is being downloaded (not yet cached), a loading indicator must be shown.
- [ ] The loading indicator should be centered on the screen.
- [ ] The loading indicator should disappear once the chapter is loaded.
- [ ] If an error occurs during download, an error message should be shown instead of the loader.

## Priorities
- **P1**: Show a basic `CircularProgressIndicator` during `BibliaLoading` state in `TelaDeLeitura`.
- **P2**: Add a descriptive text like "Baixando Bíblia..." to the loader.
