# Feature Specification Guide

This guide explains how to document new features in the Holy project using the standardized `spec.md` format.

## Purpose

Standardized documentation ensures that:
1. Developers understand the requirements before coding.
2. QA Engineers have clear acceptance criteria for testing.
3. Stakeholders can verify that the feature delivers the intended value.

## The `spec.md` Structure

Every feature must have a `spec.md` file in its corresponding directory under `specs/`.

### 1. Header
Includes the feature name, branch, creation date, and the original user input.

### 2. User Scenarios & Testing (Mandatory)
This is the most important section. It describes the feature from the user's perspective.
- **User Stories**: Prioritized (P1, P2, P3) journeys.
- **Independent Test**: How to verify the story in isolation.
- **Acceptance Scenarios**: "Given/When/Then" format.

### 3. Edge Cases
Identifies boundary conditions and error scenarios.

### 4. Requirements (Mandatory)
Functional requirements (FR-001, FR-002, etc.) that the system must fulfill.

### 5. Key Entities
Describes the data involved in the feature.

### 6. Success Criteria (Mandatory)
Measurable outcomes (SC-001, SC-002, etc.) to determine if the feature is successful.

## Best Practices

- **No Implementation Details**: Avoid mentioning specific programming languages, frameworks, or database tables. Focus on *what* the system does, not *how*.
- **Testability**: Every requirement and scenario must be testable.
- **Clarity**: Use plain language that non-technical stakeholders can understand.

## Template

The template is located at `.specify/templates/spec-template.md`.
