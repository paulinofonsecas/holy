# Implementation Plan: Download Loader

## Tech Stack
- Flutter
- flutter_bloc

## Proposed Changes

### 1. UI Update in `TelaDeLeitura`
- Update the `builder` in `BlocConsumer<BibliaBloc, BibliaState>` to return a `Center` with a `CircularProgressIndicator` when the state is `BibliaLoading` (or any state other than `BibleChapterLoaded` or `BibleError`).

### 2. Enhanced Loading State (Optional/Future)
- If we want to distinguish between "Loading from Cache" and "Downloading from GitHub", we might need to update `BibliaBloc` and `BibliaState` to include a `isDownloading` flag or a new `BibliaDownloading` state.
- For now, the user just wants a loader while it's being "baixada" (downloaded), which currently happens during the `BibliaLoading` state triggered by `GetChapter`.

## Project Structure
- `lib/features/biblia/widgets/tela_de_leitura.dart`: Main file to update.
