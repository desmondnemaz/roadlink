# ROADLINK — BACKEND ENGINEERING RULES

**Document:** BACKEND_RULES.md  
**Project:** Roadlink  
**Backend:** Java and Spring Boot  
**Database:** PostgreSQL with PostGIS

## 1. Purpose

This document establishes the engineering standards for Roadlink's backend.

The backend is responsible for application business logic, data management, authentication, authorisation, API communication, integrations and system security.

All backend development must follow these rules alongside `GEMINI.md`.

## 2. Technology Stack

Use the following technologies unless an approved architectural decision changes them:

- Java.
- Spring Boot.
- Spring Web.
- Spring Security.
- Spring Data JPA.
- Hibernate.
- PostgreSQL.
- PostGIS for geospatial operations.
- Flyway for database migrations.
- Bean Validation.
- Maven for dependency management.
- JUnit and Mockito for testing.
- Spring Boot Actuator for operational monitoring where appropriate.

Initial infrastructure:

- Supabase-hosted PostgreSQL.
- Supabase Storage for media files.
- Spring Boot as the main backend application.

Do not introduce additional infrastructure without a clear requirement.

## 3. Architecture

Use a modular monolith architecture initially.

Roadlink should have one backend application with clearly separated business modules.

Do not introduce microservices prematurely.

Recommended modules:

```text
roadlink_backend/
└── src/
    ├── main/
    │   ├── java/
    │   │   └── com/roadlink/
    │   │       ├── RoadlinkApplication.java
    │   │       │
    │   │       ├── config/
    │   │       ├── security/
    │   │       ├── common/
    │   │       │
    │   │       ├── identity/
    │   │       ├── vehicles/
    │   │       ├── social/
    │   │       ├── marketplace/
    │   │       ├── messaging/
    │   │       ├── services/
    │   │       ├── events/
    │   │       ├── geolocation/
    │   │       ├── media/
    │   │       ├── payments/
    │   │       └── notifications/
    │   │
    │   └── resources/
    │       ├── application.yml
    │       └── db/
    │           └── migration/
    │
    └── test/
```

Each module should own its business logic and data-access responsibilities.

Avoid unnecessary dependencies between modules.

## 4. Layered Architecture

Use clear separation of responsibilities.

Typical feature structure:

```text
vehicles/
├── controller/
├── service/
├── repository/
├── entity/
├── dto/
├── mapper/
└── exception/
```

Responsibilities:

### Controller

- Expose REST endpoints.
- Receive HTTP requests.
- Validate incoming request structures.
- Delegate business operations to services.
- Return appropriate HTTP responses.

Controllers must not contain substantial business logic.

### Service

- Implement business rules.
- Coordinate operations.
- Enforce application-level requirements.
- Manage transactional operations.
- Coordinate repositories and integrations.

### Repository

- Handle database access.
- Use Spring Data JPA where appropriate.
- Implement custom queries when necessary.

### Entity

- Represent persistent database structures.
- Define relationships and constraints.
- Avoid exposing entities directly through API responses.

### DTO

- Define request and response structures.
- Control which fields enter and leave the API.
- Prevent accidental exposure of internal entity fields.

### Mapper

- Convert between entities and DTOs.
- Use a consistent mapping approach.

Do not introduce unnecessary layers or abstractions.

## 5. REST API Conventions

Design predictable and consistent REST APIs.

Examples:

```text
GET    /api/v1/vehicles
GET    /api/v1/vehicles/{id}
POST   /api/v1/vehicles
PUT    /api/v1/vehicles/{id}
PATCH  /api/v1/vehicles/{id}
DELETE /api/v1/vehicles/{id}
```

Rules:

- Use consistent URL naming.
- Use appropriate HTTP methods.
- Return meaningful HTTP status codes.
- Use DTOs for requests and responses.
- Implement pagination for large collections.
- Use filtering and sorting where appropriate.
- Validate request payloads.
- Provide consistent error responses.
- Avoid exposing database implementation details.
- Version public APIs where appropriate.

## 6. Database Standards

Use PostgreSQL as the primary relational database.

Use UUIDs for identifiers where appropriate.

Rules:

- Define primary keys.
- Define foreign keys.
- Apply appropriate unique constraints.
- Apply appropriate indexes.
- Use transactions for operations that must succeed or fail together.
- Use `timestamptz` for timestamps.
- Store timestamps consistently in UTC.
- Use appropriate numeric types.
- Avoid unnecessary nullable columns.
- Avoid storing duplicated information without a clear reason.
- Use explicit relationship tables where appropriate.

Do not store passwords in plain text.

Do not store large image, video or audio binaries directly in PostgreSQL.

Store media files in the approved storage provider and retain their metadata and references in PostgreSQL.

## 7. Database Migrations

Use Flyway to manage database schema changes.

Rules:

1. All structural database changes must be represented by migration scripts.
2. Use sequential migration names.
3. Never silently modify an already-applied migration in a shared environment.
4. Create new migrations for subsequent schema changes.
5. Test migrations before deployment.
6. Avoid depending unnecessarily on Supabase-specific database features.
7. Keep migrations compatible with standard PostgreSQL wherever possible.

Example:

```text
db/migration/
├── V1__create_identity_tables.sql
├── V2__create_business_tables.sql
├── V3__create_vehicle_tables.sql
├── V4__create_social_tables.sql
└── V5__create_media_tables.sql
```

Do not manually change production database structures without a migration.

## 8. JPA and Hibernate

Use Spring Data JPA and Hibernate for normal relational persistence.

Rules:

- Define entity relationships deliberately.
- Avoid unnecessary eager loading.
- Understand lazy-loading behaviour.
- Prevent N+1 query problems.
- Use pagination for large datasets.
- Avoid serialising entities directly into REST responses.
- Use DTO projections when appropriate.
- Use transactions deliberately.
- Avoid unnecessary cascading operations.
- Define database constraints alongside application validation.

Do not use JPA for every database operation if a carefully designed native query is more appropriate.

## 9. Authentication and Authorisation

Use the approved authentication architecture.

The preferred initial design is Spring Security with token-based authentication, such as JWT, subject to the final authentication decision.

Rules:

- Hash passwords using a recognised password-hashing algorithm.
- Never store plain-text passwords.
- Validate authentication tokens.
- Enforce permissions on the backend.
- Apply role-based and resource-level authorisation where appropriate.
- Prevent users from accessing resources belonging to other users without permission.
- Protect sensitive endpoints.
- Handle expired and invalid tokens.
- Do not trust user IDs supplied by clients as proof of ownership.

Roadlink supports multiple user roles and business memberships. Do not assume that one user can only have one role or belong to one business.

Keep authentication and authorisation logic centralised and consistent.

Never expose Supabase service-role keys or other server-side secrets in Flutter or web clients.

## 10. Validation and Error Handling

Use Bean Validation for incoming request validation.

Examples:

- `@NotNull`
- `@NotBlank`
- `@Email`
- `@Size`
- `@Min`
- `@Max`

Rules:

- Validate input at API boundaries.
- Enforce business rules in services.
- Use consistent exception handling.
- Return meaningful error messages.
- Do not expose stack traces to clients.
- Do not expose sensitive database information.
- Log useful technical details securely.

Use a centralised exception-handling approach, such as `@RestControllerAdvice`.

## 11. Transactions and Data Integrity

Use transactions for operations involving multiple related database changes.

Examples:

- Creating a vehicle listing and its related records.
- Creating an order and its order items.
- Processing payment-related state changes.
- Registering users for events.
- Assigning service requests.

Rules:

- Avoid partially completed business operations.
- Apply database constraints.
- Handle concurrency appropriately.
- Avoid duplicate operations.
- Use idempotency for operations that may be retried, particularly payments and external callbacks.

## 12. Geolocation

Use PostGIS for geospatial functionality.

Roadlink may use geolocation for:

- Nearby mechanics and garages.
- Roadside assistance.
- Service provider discovery.
- Nearby events.
- Vehicle and business locations.

Rules:

- Use appropriate geography or geometry data types.
- Use spatial indexes such as GiST.
- Use suitable spatial queries such as `ST_DWithin`.
- Maintain the correct longitude and latitude order when constructing points.
- Validate geographic coordinates.
- Avoid unnecessary location collection.
- Respect user permissions and consent.
- Do not continuously track users without explicit permission.

For example, PostgreSQL point construction uses:

```sql
ST_MakePoint(longitude, latitude)
```

## 13. Media Integration

Media storage should remain separate from relational business data.

Initially use Supabase Storage, accessed through an approved server-side integration where appropriate.

Rules:

- Store file references and metadata in PostgreSQL.
- Validate file types and sizes.
- Enforce upload permissions.
- Avoid trusting filenames or MIME types supplied by clients.
- Use appropriate access policies.
- Support media deletion and cleanup.
- Prevent unauthorised access to private attachments.
- Avoid exposing private storage credentials.

Do not make the database responsible for storing large media files.

## 14. Messaging and Real-Time Features

Use REST APIs for normal message operations and WebSocket/STOMP where real-time communication is required.

Rules:

- Authenticate WebSocket connections.
- Authorise conversation membership.
- Validate message content and attachments.
- Handle message delivery and read status.
- Prevent unauthorised access to conversations.
- Handle reconnections.
- Avoid assuming that a message was delivered simply because it was submitted.

Keep messaging business logic within its own module.

## 15. Marketplace and Orders

Keep marketplace responsibilities separate from payment processing.

Core marketplace functionality may include:

- Products.
- Categories.
- Sellers.
- Inventory.
- Carts.
- Orders.
- Order items.
- Shipments.

Rules:

- Validate product availability.
- Validate quantities.
- Calculate prices on the backend.
- Never trust client-calculated totals.
- Record order item prices at the time of purchase.
- Manage order status transitions explicitly.
- Protect seller and customer information.
- Prevent unauthorised order modifications.

## 16. Payments and Monetisation

Payment integration must be designed carefully and implemented when the business is ready.

Potential future integrations include supported Zimbabwean payment providers such as Paynow, Pesepay or EcoCash, subject to verification of availability, onboarding and technical requirements.

Rules:

- Do not hardcode one payment provider into core business logic.
- Use a provider abstraction where appropriate.
- Verify payment callbacks and webhooks server-side.
- Never trust a client-side payment success message.
- Implement idempotency.
- Record transaction references.
- Maintain appropriate payment and refund records.
- Use integer minor currency units and ISO currency codes.
- Reconcile provider transactions.
- Maintain an auditable financial ledger when balances, commissions or payouts are introduced.
- Never store raw card details.

Do not implement a user wallet simply by adding a balance column to the users table.

Keep subscriptions, promotions, event tickets and other purchasable products separate from payment transaction records.

## 17. Security

Security must be considered in every backend feature.

Rules:

- Use environment variables or approved secret-management systems.
- Never commit passwords, tokens or private keys.
- Validate incoming data.
- Apply authentication and authorisation.
- Protect against injection attacks.
- Use parameterised queries.
- Configure CORS deliberately.
- Apply rate limiting where appropriate.
- Avoid exposing sensitive information in logs.
- Keep dependencies updated.
- Review security advisories before upgrading critical dependencies.
- Protect file uploads and external integrations.

Do not rely exclusively on Flutter-side validation or access restrictions.

## 18. Performance and Scalability

Optimise based on measured requirements.

Prioritise:

- Database indexing.
- Efficient queries.
- Pagination.
- Appropriate connection pooling.
- DTO projections.
- Avoiding N+1 queries.
- Efficient media handling.
- Caching only where beneficial.
- Background processing for expensive tasks.

Do not introduce Redis, message brokers, microservices or distributed infrastructure without a demonstrated requirement.

## 19. Testing

Use:

- JUnit.
- Mockito.
- Spring Boot testing support.
- Integration tests.
- Database integration tests.

Test important functionality, including:

- Authentication and permissions.
- Vehicle creation and listing.
- Marketplace operations.
- Order processing.
- Social interactions.
- Messaging permissions.
- Geospatial searches.
- Payment callback verification.

Use an appropriate test database or isolated test environment.

Do not claim that tests pass unless they have actually been executed.

## 20. Configuration and Environments

Separate configuration for development, testing and production.

Rules:

- Do not commit production credentials.
- Use environment-specific configuration.
- Avoid hardcoded connection strings.
- Keep secrets outside source control.
- Configure logging appropriately.
- Keep production debugging disabled.
- Use health checks and monitoring where appropriate.

## 21. AI-Assisted Backend Development

Before modifying backend code:

1. Inspect the relevant classes and packages.
2. Understand the existing architecture.
3. Understand the database relationships involved.
4. Identify API and security implications.
5. Explain the proposed changes.
6. Implement in small increments.
7. Run relevant tests.
8. Explain the results and any remaining limitations.

Do not rewrite entire modules without justification.

Do not invent database tables, entity relationships or API contracts without checking the existing design.

Do not generate unnecessary abstractions or infrastructure.

When database changes are needed, explain the required migration before implementing it.

## 22. Final Principle

The backend must remain secure, maintainable, consistent and capable of supporting Roadlink as it grows.

Keep business logic in the backend. Protect data integrity. Design APIs deliberately. Make database changes through migrations. Test before declaring completion.