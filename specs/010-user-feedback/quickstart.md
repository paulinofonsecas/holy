# Quickstart: User Feedback

## How to use

### 1. Accessing the About Page
1. Open the app.
2. Navigate to the **Profile** tab in the bottom navigation bar.
3. Tap on the **About** button.
4. View app version, developer info, and social links.

### 2. Reporting a Problem
1. Navigate to the **Profile** tab.
2. Tap on **Report a Problem**.
3. The feedback UI will appear, allowing you to:
   - Draw on the screen to highlight the issue.
   - Write a description of the problem.
4. Tap **Submit**.
5. Wait for the confirmation message.

## Developer Notes
- Ensure Firebase is correctly initialized in `main.dart`.
- The `BetterFeedback` widget must wrap the `MaterialApp`.
- Use `FeedbackService` to handle the submission logic.
