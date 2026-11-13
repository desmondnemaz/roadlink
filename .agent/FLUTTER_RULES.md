# ROADLINK — FLUTTER ENGINEERING RULES

**Document:** FLUTTER_RULES.md  
**Project:** Roadlink  
**Platform:** Flutter (Android, iOS and Web)

## 1. Purpose

This document defines the technical standards and implementation conventions for Roadlink's Flutter application.

All Flutter development must follow these rules alongside the general engineering instructions in `GEMINI.md`.

The application must be maintainable, responsive, scalable, secure and optimised for users on both reliable and poor internet connections.

## 2. Technology Stack

Use the following technologies unless an approved architectural decision changes them:

- Flutter and Dart.
- flutter_bloc for state management.
- Cubit for straightforward state management.
- Bloc for complex event-driven workflows.
- go_router for navigation and routing.
- Dio for HTTP communication.
- Equatable where value equality is useful.
- get_it for dependency injection.
- shared_preferences for appropriate lightweight local preferences.
- Supabase Storage for initial media storage.
- REST APIs provided by the Roadlink Spring Boot backend.

Do not introduce additional packages without explaining their purpose and why existing packages are insufficient.

## 3. Project Architecture

Use a feature-first architecture.

Organise code around application features rather than placing all screens, models, services or widgets into large shared folders.

Recommended structure:

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   │   └── app_router.dart
│   └── theme/
│       ├── app_theme.dart
│       ├── light_theme.dart
│       └── dark_theme.dart
│
├── core/
│   ├── constants/
│   ├── errors/
│   ├── network/
│   ├── services/
│   ├── utils/
│   └── dependency_injection/
│
├── shared/
│   ├── widgets/
│   ├── components/
│   └── models/
│
└── features/
    ├── onboarding/
    ├── authentication/
    ├── home/
    ├── vehicles/
    ├── marketplace/
    ├── social/
    ├── messaging/
    ├── events/
    ├── services/
    └── profile/
```

A feature should contain only the layers it actually needs.

For features that require separation of responsibilities, use:

```text
feature_name/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
│
└── presentation/
    ├── cubit/
    ├── bloc/
    ├── pages/
    └── widgets/
```

Do not create empty layers or unnecessary abstractions simply to satisfy a folder structure.

## 4. State Management

Use Cubit or Bloc for application state.

### Cubit

Use Cubit for relatively straightforward operations, such as:

- Loading a user profile.
- Fetching vehicle categories.
- Updating profile information.
- Managing simple filters.
- Loading marketplace categories.

### Bloc

Use Bloc when workflows involve multiple events, complex transitions or event-driven processing.

Examples include:

- Messaging workflows.
- Complex notifications.
- Multi-step listing creation.
- Advanced marketplace order workflows.

Rules:

1. Do not place substantial business logic inside widgets.
2. Do not use `setState` as a replacement for application-level state management.
3. Keep state classes predictable and focused.
4. Handle loading, success, empty and error states.
5. Avoid unnecessary duplicate API requests.
6. Do not mix unrelated feature states into one Cubit or Bloc.

## 5. Navigation

Use go_router for application navigation.

Rules:

- Centralise route definitions.
- Use named routes where appropriate.
- Support route parameters and query parameters.
- Implement authentication redirects where necessary.
- Support deep linking where required.
- Keep navigation logic separate from business logic.
- Avoid scattering hardcoded route strings throughout the application.

## 6. UI and Design System

The approved Figma designs are the primary visual reference.

Do not redesign, reinterpret or introduce new layouts without approval.

Before implementing a screen:

1. Inspect its corresponding Figma design.
2. Identify the layout and component hierarchy.
3. Identify colours, typography, spacing and dimensions.
4. Identify reusable components.
5. Check light and dark theme requirements.
6. Implement the screen.
7. Compare the result with the reference design.

### Design system rules

- Use centralised colour definitions.
- Use centralised typography definitions.
- Use consistent spacing and sizing tokens.
- Use reusable buttons, inputs, cards and other shared components.
- Support light and dark themes.
- Avoid unnecessary hardcoded styling.
- Maintain consistent border radii, shadows and icon sizing.

Do not introduce arbitrary colours or typography styles.

## 7. Widget Development

Build small, reusable and understandable widgets.

Rules:

- Keep widgets focused on one responsibility.
- Extract repeated UI into reusable components.
- Avoid excessively large widget trees.
- Separate presentation from data retrieval and business logic.
- Use const constructors wherever practical.
- Avoid unnecessary widget rebuilds.
- Use appropriate keys for dynamically generated lists.

Do not create abstractions for components that are only used once unless there is a clear maintenance or readability benefit.

## 8. API Integration

The Spring Boot backend is the authoritative source of application business data.

Use Dio for HTTP requests.

Rules:

1. Centralise API configuration.
2. Centralise request and response handling.
3. Use appropriate request timeouts.
4. Handle network failures.
5. Handle authentication failures.
6. Parse API responses into appropriate models.
7. Keep API communication inside data-layer classes.
8. Do not make HTTP requests directly inside UI widgets.
9. Avoid hardcoded API URLs throughout the application.
10. Never expose secret credentials in the Flutter application.

Do not connect Flutter directly to PostgreSQL.

Do not implement critical business rules exclusively in the Flutter client.

## 9. Authentication and Security

Authentication must follow the approved backend authentication architecture.

Rules:

- Never store plain-text passwords.
- Never hardcode secrets, API keys or private credentials.
- Store authentication tokens securely using an appropriate secure-storage solution.
- Handle expired sessions.
- Handle logout and session invalidation.
- Enforce permissions on the backend.
- Do not assume that hiding a button provides security.
- Avoid exposing private user information in application logs.

## 10. Media and File Handling

Roadlink will support vehicle images, marketplace product images, posts, videos and messaging attachments.

Rules:

- Use appropriate image compression.
- Resize images before uploading where appropriate.
- Avoid unnecessarily large uploads.
- Support image previews.
- Show upload progress.
- Handle interrupted uploads.
- Use pagination and lazy loading for media feeds.
- Display thumbnails before loading larger media.
- Avoid loading every image when a screen opens.
- Store media references and metadata rather than large binary files in application models.

Use the approved media-storage integration.

## 11. Performance and Network Optimisation

Roadlink must work well on mobile data and unstable networks.

Prioritise:

- Lazy loading.
- Pagination.
- Image compression.
- Thumbnail generation.
- Efficient list rendering.
- Appropriate caching.
- Request cancellation where appropriate.
- Avoiding unnecessary API requests.
- Avoiding unnecessary rebuilds.
- Efficient navigation and screen initialisation.

Do not load an entire social feed, marketplace catalogue or message history at once.

Do not block the initial application interface while unrelated data is loading.

Use meaningful loading indicators and error states instead of prolonged blank screens.

## 12. Forms and Validation

Rules:

- Validate user input before submitting.
- Provide understandable validation messages.
- Avoid duplicating backend validation rules as the only validation mechanism.
- Handle backend validation responses.
- Prevent accidental duplicate submissions.
- Show submission progress.
- Preserve appropriate form data when a recoverable error occurs.

The backend remains responsible for authoritative validation.

## 13. Testing

Write tests for important application behaviour.

Use:

- Unit tests for business and state-management logic.
- Widget tests for reusable UI and screen behaviour.
- Integration tests for important end-to-end workflows.

Prioritise testing:

- Authentication.
- Navigation.
- Vehicle listing creation.
- Marketplace interactions.
- Social feed operations.
- Messaging.
- API error handling.

Never claim that a test passes without executing it.

## 14. Code Quality

- Use clear and descriptive names.
- Follow Dart conventions.
- Avoid unnecessary code duplication.
- Remove unused imports and dead code.
- Avoid unnecessary dependencies.
- Keep methods and classes reasonably focused.
- Handle exceptions deliberately.
- Document complex logic.
- Do not suppress warnings without understanding their cause.

## 15. AI-Assisted Development

Before modifying Flutter code:

1. Inspect the relevant existing files.
2. Understand the current architecture.
3. Identify the intended change.
4. Explain the proposed implementation.
5. Make focused changes.
6. Run relevant formatting, analysis and tests.
7. Explain what changed and what remains incomplete.

Do not rewrite entire features when a smaller change is sufficient.

Do not delete existing functionality without explicit approval.

Do not generate mock implementations that are presented as production-ready functionality.

Mock data may be used during UI development, but it must be isolated from production data sources and clearly identified.

## 16. Final Principle

Build Roadlink's Flutter application with maintainability, performance, usability and consistency in mind.

Understand the existing code before changing it. Follow the approved design system. Implement incrementally. Test before declaring completion.