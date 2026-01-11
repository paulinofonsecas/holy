# Implementation Plan - Book Modal Navigation & Accordion Behavior

The goal of this feature is to improve the usability of the Book Selection Modal by implementing an accordion behavior (only one book expanded at a time) and automatically scrolling to the current book when the modal opens.

## User Review

- **Accordion Behavior**: When a user expands a book, any other currently expanded book should collapse. This prevents the modal from becoming cluttered and simplifies navigation.
- **Auto-Scroll to Current Book**: Opening the Book Modal should automatically scroll to and expand the currently active book, providing immediate context.

## Proposed Changes

### Logic & State Management
- **lib/features/biblia/bloc/book_selection_cubit.dart**:
    - Modify `setBookExpanded` and `toggleBookExpansion` to ensure `expandedBookIds` contains at most one element.
    - If `expanded == true`, clear the set and add the new `bookId`.
    - If `expanded == false`, clear the set.

### UI & Navigation
- **lib/features/biblia/modals/switch_book_modal.dart**:
    - Update `show` method to handle auto-scrolling.
    - Instead of just passing a generic `scrollOffset` from state, we will calculate or trigger a scroll to the current `state.bookId`.
    - Since `SliverList` items are built lazily, we will implement a mechanism to scroll to the index of the current book.

- **lib/features/biblia/modals/modalpages/list_bible_books_modalpage.dart**:
    - Add a `ScrollController` listener or use a `PostFrameCallback` to scroll to the current book after the modal is built.
    - Map `bookId` to its index in `BibleBooks.values`.
    - Estimate the scroll offset: `offset = index * estimatedItemHeight`.
    - Special cases for Testament headers (Genesis and Matthew).

## Verification Plan

### Automated Tests (If requested)
- Unit tests for `BookSelectionCubit` to verify that `expandedBookIds` never exceeds a size of 1.
- Verify that expanding Book B clears Book A from `expandedBookIds`.

### Manual Verification
- Open the application at a book in the middle of the Bible (e.g., Psalms).
- Click the Book AppBar.
- **Verify**: The modal opens and "Salmos" is visible and expanded.
- **Verify**: Clicking another book (e.g., Genesis) expands it and collapses "Salmos".
- **Verify**: Scrolling manually updates the persistent offset.
