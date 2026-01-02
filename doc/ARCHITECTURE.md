# Architecture Overview - Holy App

This document provides a high-level overview of the Holy application's architecture using the C4 Model, managed via C4-PlantUML.

## System Overview

Holy is a modern Bible application built with Flutter, focusing on speed, offline access, and user experience.

## C4 Model (C4-PlantUML)

We use **C4-PlantUML** to define our architecture as code. This allows us to maintain version-controlled diagrams that are easy to read and update.

### How to view the diagrams in VS Code

To visualize the architecture diagrams directly in VS Code:

1.  Ensure the **PlantUML** extension (`jebbs.plantuml` or `apouch.plantuml`) is installed.
2.  Open the `.puml` files in the [doc/architecture/](architecture/) directory.
3.  Press `Alt + D` to open the PlantUML preview.

### Diagrams

- **[System Context](architecture/context.puml)**: High-level view of the Holy App's relationship with users and external systems.
- **[Container Diagram](architecture/container.puml)**: Internal structure of the Holy App, including the Flutter app, SQLite database, and Bible Server.

## Technical Stack

- **Frontend**: Flutter (Dart)
- **State Management**: Bloc
- **Local Storage**: SQLite (sqflite)
- **Backend**: Bible Server (Dart/Shelf)
- **Cloud Services**: Firebase (Analytics, Messaging)