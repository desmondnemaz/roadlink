# ROADLINK — MASTER ENGINEERING INSTRUCTIONS

**Project:** Roadlink  
**Document:** GEMINI.md  
**Purpose:** Master project instructions for AI-assisted software development.

---

# 1. PROJECT OVERVIEW

Roadlink is an automotive-focused social networking and marketplace platform designed to connect car enthusiasts, vehicle owners, automotive businesses, service providers, sellers and automotive communities.

The platform aims to bring the automotive ecosystem into one digital environment.

Roadlink is not intended to be a generic social media application. Its features, content, services and marketplace must remain focused on the automotive industry.

The initial target market is Zimbabwe, with the architecture designed to support future expansion into other African markets.

## 1.1 Core Platform Features

Roadlink is expected to support the following major modules:

1. **Authentication and User Management**
   - User registration and login.
   - User profiles.
   - Multiple user roles.
   - Business accounts and memberships.
   - Account verification and permissions.

2. **Automotive Social Networking**
   - Posts and comments.
   - Likes and reactions.
   - Following users.
   - Sharing and saving posts.
   - Automotive communities.
   - Image and video content.

3. **Vehicles**
   - Vehicle profiles.
   - Vehicle specifications.
   - Vehicle ownership information.
   - Vehicle listings.
   - Vehicle discovery and filtering.
   - Favourites and saved listings.

4. **Marketplace**
   - Automotive products.
   - Spare parts and accessories.
   - Product categories.
   - Sellers and businesses.
   - Inventory.
   - Shopping carts and orders.

5. **Automotive Services**
   - Mechanics and garages.
   - Towing and roadside assistance.
   - Car washes.
   - Tyre services.
   - Automotive technicians.
   - Service discovery and bookings.

6. **Messaging**
   - Private conversations.
   - Group conversations.
   - Text messages.
   - Media attachments.
   - Message delivery and read status.
   - Notifications.

7. **Events and Communities**
   - Car shows.
   - Automotive exhibitions.
   - Meetups.
   - Event registration.
   - Event tickets.
   - Community activities.

8. **Geolocation**
   - Nearby automotive services.
   - Business locations.
   - Nearby events.
   - Service-provider discovery.
   - Roadside assistance locations.

9. **Monetisation**
   - Featured vehicle listings.
   - Business subscriptions.
   - Promoted content.
   - Marketplace commissions.
   - Event ticketing.
   - Premium memberships.
   - Advertising.
   - Future creator earnings and payouts.

These features represent the product vision. Do not assume every feature must be implemented immediately.

---

# 2. TECHNOLOGY ARCHITECTURE

Use the approved architecture unless an architectural change is explicitly discussed and approved.

## 2.1 Initial Technology Stack

| Component | Technology |
|---|---|
| Mobile application | Flutter |
| Initial web application | Flutter Web |
| Backend | Java and Spring Boot |
| Database | PostgreSQL |
| Initial database hosting | Supabase |
| Geospatial functionality | PostGIS |
| Initial media storage | Supabase Storage |
| Backend ORM | Spring Data JPA / Hibernate |
| Database migrations | Flyway |
| Mobile state management | flutter_bloc |
| Navigation | go_router |
| HTTP communication | Dio |
| Real-time communication | Spring WebSocket / STOMP |
| Build and dependency management | Maven |

The initial web application will use Flutter Web. A separate Next.js and TypeScript web application may be introduced later.

Both Flutter and Next.js applications should communicate with the same Spring Boot backend APIs.

## 2.2 Backend Architecture

Use a modular monolith architecture initially.

Do not introduce microservices prematurely.

The backend should contain logically separated modules, including:

- Identity.
- Vehicles.
- Social.
- Marketplace.
- Messaging.
- Services.
- Events.
- Geolocation.
- Media.
- Payments.
- Notifications.

Modules should have clear responsibilities and avoid unnecessary coupling.

## 2.3 Database Architecture

Use one PostgreSQL database with logically separated application modules.

Use PostGIS for geospatial functionality.

Use Flyway to manage database schema changes.

The database should support:

- Referential integrity.
- Appropriate primary and foreign keys.
- Unique constraints.
- Indexes.
- Transactions.
- Consistent timestamp handling.
- Efficient querying.
- Future expansion.

Keep the database design as portable as reasonably possible.

Avoid unnecessary dependencies on Supabase-specific database functionality so the database can be migrated to independent PostgreSQL hosting in the future.

## 2.4 Storage Architecture

Store media files separately from relational business data.

Use the approved storage provider for images, videos and attachments.

PostgreSQL should contain media metadata and storage references rather than large binary files.

Do not expose private storage credentials in client applications.

---

# 3. MASTER ENGINEERING PRINCIPLES

All development must follow these principles:

1. Understand the existing system before modifying it.
2. Follow the approved architecture.
3. Prefer simple and maintainable solutions.
4. Avoid unnecessary complexity.
5. Implement incrementally.
6. Reuse existing functionality where appropriate.
7. Avoid unnecessary duplication.
8. Maintain clear separation of responsibilities.
9. Prioritise security and data integrity.
10. Test changes before declaring completion.
11. Do not silently change established architectural decisions.
12. Do not remove existing functionality without approval.

Do not introduce technologies simply because they are popular.

Every new dependency, service or architectural component must have a clear purpose.

---

# 4. SPECIALISED ENGINEERING DOCUMENTS

Roadlink maintains separate engineering documents for different parts of the system.

These documents complement this master instruction file.

| Document | Responsibility |
|---|---|
| GEMINI.md | General engineering principles, architecture and AI behaviour |
| FLUTTER_RULES.md | Flutter and Dart implementation conventions |
| BACKEND_RULES.md | Java, Spring Boot and database conventions |

## Mandatory Instructions

Before performing a development task:

1. Identify which part of Roadlink is affected.
2. Read the relevant specialised instruction document.
3. Inspect the existing implementation.
4. Follow the relevant technical conventions.
5. Consider the impact on other modules.

For Flutter development, consult `FLUTTER_RULES.md`.

For backend development, consult `BACKEND_RULES.md`.

For tasks involving both applications, consult both documents.

If a specialised instruction conflicts with an approved architectural decision, do not silently choose a different architecture. Explain the conflict and request clarification.

---

# 5. DESIGN AND FIGMA IMPLEMENTATION

The approved Figma designs are the primary visual reference for the application's user interface.

Do not independently redesign approved screens.

Before implementing a screen:

1. Inspect the relevant Figma reference.
2. Understand its layout.
3. Identify the component hierarchy.
4. Identify typography and colours.
5. Identify spacing and sizing.
6. Identify reusable components.
7. Understand navigation and interaction behaviour.
8. Implement the screen.
9. Compare the implementation against the reference.

Maintain consistency between light and dark themes.

Do not invent new visual styles, colours, layouts or interactions without justification and approval.

If a design is unclear or incomplete, identify the missing information rather than guessing.

---

# 6. DATA AND BUSINESS LOGIC

The Spring Boot backend is the authoritative source of business rules and application data.

Flutter and future web clients should consume backend APIs.

Rules:

- Do not connect Flutter directly to PostgreSQL.
- Do not expose database credentials in client applications.
- Do not rely on client-side validation for critical business rules.
- Do not calculate authoritative transaction totals exclusively on the client.
- Do not trust client-supplied ownership information.
- Enforce permissions on the backend.
- Validate data before persistence.
- Preserve data integrity through database constraints and transactions.

Keep business logic in the appropriate backend service or domain module.

---

# 7. SECURITY AND PRIVACY

Security must be considered throughout development, not added at the end.

Mandatory principles:

- Never store plain-text passwords.
- Never commit secrets or private credentials.
- Never expose service-role keys in client applications.
- Enforce authentication and authorisation on the backend.
- Protect private user and business information.
- Validate uploaded files.
- Protect APIs against unauthorised access.
- Avoid exposing sensitive information in logs.
- Respect user privacy and consent.

Geolocation must be user-controlled.

Do not implement continuous location tracking without explicit user permission.

Roadside assistance may require temporary location sharing, but this must be limited to the intended purpose and duration.

---

# 8. PERFORMANCE AND NETWORK CONDITIONS

Roadlink must be designed for real-world network conditions, including unreliable mobile internet and limited bandwidth.

Prioritise:

- Image compression.
- Video optimisation.
- Thumbnail generation.
- Lazy loading.
- Pagination.
- Efficient API requests.
- Appropriate caching.
- Efficient database queries.
- Background processing where appropriate.
- Avoiding unnecessary screen rebuilds.
- Responsive interfaces.

Do not load entire feeds, catalogues, message histories or media collections at once.

Avoid blank screens while the application is loading.

Provide meaningful loading, empty and error states.

Performance decisions should be based on actual requirements and measurements rather than unnecessary infrastructure.

---

# 9. API AND MODULE INTEGRATION

The Flutter application and future Next.js application should use consistent backend API contracts.

Rules:

- Maintain predictable REST API structures.
- Use appropriate HTTP methods and status codes.
- Use DTOs for API communication.
- Implement pagination where necessary.
- Handle authentication consistently.
- Maintain clear module boundaries.
- Document important API contracts.
- Avoid duplicating business logic between clients.

When changing an API, consider its effect on all connected clients.

Do not break existing functionality without identifying the impact and obtaining approval.

---

# 10. PAYMENTS AND MONETISATION

Roadlink's architecture should accommodate future monetisation.

However, do not introduce a full payment system before its requirements and business model are defined.

Potential future revenue streams include:

- Featured listings.
- Business subscriptions.
- Promoted posts.
- Marketplace commissions.
- Event ticketing.
- Premium memberships.
- Advertising.
- Creator earnings.

Payment integration should use an appropriate provider abstraction.

Never trust client-side payment confirmations.

Verify payment callbacks and webhooks server-side.

Use idempotency and maintain auditable transaction records.

Do not implement an informal wallet or financial balance system without proper ledger and reconciliation design.

---

# 11. TESTING AND QUALITY ASSURANCE

Testing is required throughout development.

Use appropriate testing strategies for each component.

Examples:

- Unit tests.
- Widget tests.
- Integration tests.
- API tests.
- Database integration tests.
- Security tests.
- Performance tests.

Prioritise critical workflows, including:

- Registration and login.
- Profile management.
- Vehicle listing creation.
- Social interactions.
- Marketplace operations.
- Orders.
- Messaging.
- Service requests.
- Event registration.
- Payment processing when introduced.

Do not claim that code works or tests pass unless the relevant implementation has actually been executed and verified.

Clearly distinguish between:

- Implemented.
- Partially implemented.
- Tested.
- Not tested.
- Mock implementation.
- Production-ready implementation.

---

# 12. AI DEVELOPMENT BEHAVIOUR

Gemini must act as an engineering assistant, not an uncontrolled project-rewriting agent.

The developer wants to understand the implementation and maintain control of architectural decisions.

## 12.1 Before Making Changes

Always:

1. Inspect the relevant files.
2. Understand the current implementation.
3. Identify existing dependencies.
4. Identify affected modules.
5. Understand relevant database relationships and API contracts.
6. Explain the proposed changes.
7. Implement only what is necessary.

Do not scan or rewrite the entire project unnecessarily.

## 12.2 During Implementation

- Work in small, understandable increments.
- Explain important technical decisions.
- Preserve existing working functionality.
- Follow the project's coding conventions.
- Reuse appropriate existing components.
- Avoid unnecessary dependencies.
- Avoid creating duplicate classes or services.
- Do not invent missing requirements.
- Do not introduce mock data as if it were real production data.

## 12.3 When Modifying Existing Code

Do not:

- Delete files without justification.
- Rewrite entire modules unnecessarily.
- Replace existing architecture without approval.
- Remove working functionality to simplify an implementation.
- Modify unrelated files.
- Change database schemas without explaining the migration.
- Hardcode secrets or credentials.

If a requested change requires a significant architectural modification, explain the implications first.

## 12.4 Explaining Code

When providing implementation guidance:

- Explain what the code does.
- Explain why the implementation is necessary.
- Explain how data flows through the application.
- Explain important dependencies.
- Explain how components communicate.
- Explain potential errors and edge cases.
- Explain how to test the implementation.

Prefer teaching the underlying concepts rather than providing code without explanation.

---

# 13. DEPENDENCY MANAGEMENT

Do not add dependencies unnecessarily.

Before introducing a new package or library:

1. Check whether an existing dependency already supports the requirement.
2. Explain why a new dependency is necessary.
3. Consider maintenance and security.
4. Consider compatibility with the current project versions.
5. Avoid introducing multiple packages that perform the same function.

Do not upgrade major dependencies without considering compatibility and regression risks.

---

# 14. DOCUMENTATION

Maintain useful technical documentation as Roadlink grows.

Important documentation areas include:

```text
documentation/
├── architecture/
├── database/
├── api/
├── requirements/
├── deployment/
├── security/
└── development/
```

Document important decisions, including:

- Architecture changes.
- Database relationships.
- API contracts.
- Authentication flows.
- Third-party integrations.
- Deployment procedures.
- Security requirements.
- Payment integrations.

Do not create documentation that simply duplicates existing instructions without adding value.

---

# 15. DEVELOPMENT WORKFLOW

Follow this general development process:

**Step 1 — Understand**

Inspect the relevant requirements, designs, code and architecture.

**Step 2 — Plan**

Identify the affected modules, files, data structures and dependencies.

**Step 3 — Explain**

Present the intended implementation and important decisions.

**Step 4 — Implement**

Make focused changes in manageable increments.

**Step 5 — Validate**

Run formatting, static analysis, tests and relevant application checks.

**Step 6 — Review**

Check for regressions, security issues and architectural inconsistencies.

**Step 7 — Report**

Explain what was implemented, what was tested and what remains outstanding.

Do not skip validation simply because the implementation appears straightforward.

---

# 16. FINAL ENGINEERING PRINCIPLE

Roadlink must be developed as a maintainable automotive technology platform, not as a collection of disconnected screens and features.

Understand before changing.

Design before implementing.

Keep responsibilities separated.

Protect data and users.

Build incrementally.

Test before declaring completion.

Prioritise quality, performance, security and long-term maintainability over unnecessary complexity.