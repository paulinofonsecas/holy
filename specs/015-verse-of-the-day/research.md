# Research: Verse of the Day

## Decision: Navigation Stack Reset
- **Rationale**: The user wants to guarantee the app goes to the reading screen regardless of current location.
- **Findings**: `MainScaffold` currently switches the tab but doesn't pop modals or sub-pages.
- **Decision**: Update `_handleNotificationTap` in `MainScaffold` to use `Navigator.popUntil(context, (route) => route.isFirst)` before switching tabs and loading the verse.

## Decision: Random Verse Selection in `bible_handler`
- **Findings**: `SqlBibleSearchProvider` already implements `getRandomVerse(versionId, bookIds)` using SQLite `ORDER BY RANDOM() LIMIT 1`.
- **Decision**: Use the existing implementation.

## Decision: Immediate Scheduling for Same-Day
- **Findings**: The current `VerseOfTheDayService.scheduleNextNotifications` uses `scheduledDate.isBefore(now)` to decide whether to schedule for today or skip.
- **Decision**: Ensure that if `i=0` and the time is 5 minutes from now, it stays scheduled for today. The current logic `DateTime(now.year, now.month, now.day + i, settings.hour, settings.minute)` works correctly for this.

## Decision: Project Pattern Consistency
- **Findings**: The project uses both BLoC and Stacked. `VerseOfTheDayService` is currently a plain service injected via `RepositoryProvider`. `MainScaffold` uses BLoC.
- **Decision**: Continue using BLoC for UI interactions in `MainScaffold`.

## Consolidated Decisions

| Decision | Rationale | Alternatives |
|----------|-----------|--------------|
| Navigator.popUntil | Resets stack to root before tab switch | Direct tab switch only (rejected: keeps modals open) |
| Reuse bible_handler | Avoid logic duplication | Custom SQL query in feature (rejected: breaks abstraction) |
| 7-day Pre-Schedule | Ensures variety offline | Background task (rejected: more complex to implement reliably) |
| real system notification for test | Validates full flow including clicks | In-app snackbar (rejected: doesn't test tap handler) |
