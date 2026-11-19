I reviewed your IronBook repository tree, source, and [Issue #106 — New docs needed in home project](<https://github.com/ironbook-labs/ironbook/issues/106?utm_source=chatgpt.com>). The issue identifies documentation for the API and Operations, along with an update to the Changelog, as remaining work after the Privacy Policy, Sitemap, Architecture, and Security documentation were addressed.

Below are copy-and-paste-ready Markdown drafts for those remaining sections. I've based them on the repository structure and configuration, and kept implementation-dependent details conservative so the documentation doesn't promise behavior that the source hasn't established.

## 1. API documentation

Suggested file: `apps/home/src/app/docs/api/page.tsx` or the equivalent API documentation page in your existing docs structure.

# IronBook API Reference

## Overview

IronBook provides a backend API implemented in Rust using Axum for HTTP REST endpoints and tonic for gRPC communication.

Both transports expose system, authentication, and user-related functionality. The API uses PostgreSQL for persistent storage, with SQLx managing database access and migrations.

The API source code is located in `apps/api/`.

## API Transports

IronBook supports two API transports:

- **REST API:** HTTP endpoints that accept and return JSON where applicable.
- **gRPC API:** RPC services defined using Protocol Buffers and implemented with tonic.

The REST API and gRPC services share the underlying application service layer.

### REST API Base URL

The base URL depends on your deployment configuration.

For local development, use the address and port configured for your API server. When deploying to production, use the URL assigned to your deployment.

### gRPC Endpoint

The current gRPC server listens on port `50051` and binds to `0.0.0.0` by default.

Configure your firewall and network access appropriately before exposing this port.

## Authentication

IronBook uses API tokens to authorize supported API operations.

For HTTP endpoints that require an API token in the `Authorization` header, provide the token as follows:

```
Authorization: YOUR_API_TOKEN
```

The API also issues user authentication tokens through its registration and login functionality.

Do not confuse an API token used to authorize an API operation with a user authentication token returned after successful registration or login.

Keep all tokens confidential. Do not commit them to source control, expose them in client-side logs, or include them in publicly accessible documentation.

The exact authentication requirements depend on the endpoint being called.

## REST Endpoints

The following HTTP routes are registered by the current API implementation.

| Method | Endpoint | Description |
| --- | --- | --- |
| `GET` | `/` | Returns the API greeting. |
| `GET` | `/health` | Returns a health report. |
| `POST` | `/generate_api_token` | Generates an API token for a client. |
| `POST` | `/auth/register` | Registers a user. |
| `POST` | `/auth/login` | Authenticates a user. |
| `GET` | `/users/{id}` | Retrieves a user by ID. |
| `GET` | `/users/search` | Searches for users. |

The API's deployed base URL must be prepended to each endpoint path.

### Health Check

```
GET /health
```

Returns a health report from the API.

Use this endpoint for basic service health checks. A successful health response should not automatically be interpreted as proof that every external dependency or client integration is functioning correctly.

### Generate an API Token

```
POST /generate_api_token
Content-Type: application/json
```

Generates an API token for a client.

The request accepts client-related information, including a client name and owner email. Depending on the implementation and deployment state, an existing API token may also be supplied for authorization.

Consult the current request model and service implementation before constructing a production request.

### Register a User

```
POST /auth/register
Content-Type: application/json
Authorization: YOUR_API_TOKEN
```

The registration request contains the following fields:

```
{
  "email": "user@example.com",
  "username": "example_user",
  "password": "replace-with-a-secure-password"
}
```

The API validates the supplied API token and checks whether the username or email address already exists.

A successful registration returns an authentication token.

### Log In

```
POST /auth/login
Content-Type: application/json
Authorization: YOUR_API_TOKEN
```

The login request contains:

```
{
  "email": "user@example.com",
  "password": "replace-with-your-password"
}
```

A successful login returns an authentication token.

### Retrieve a User

```
GET /users/{id}
```

Retrieves a user by their numeric identifier.

Replace `{id}` with the actual user ID. The response fields and access requirements should be verified against the current implementation before using this endpoint in an external integration.

### Search for Users

```
GET /users/search
```

Searches for users using the query parameters supported by the current search implementation.

Refer to the user service and request models for the supported filters and exact response structure.

## gRPC Services

IronBook exposes the following gRPC services:

- **SystemService:** Greeting, health reporting, and API token generation.
- **AuthService:** User registration and login.
- **UsersService:** Retrieving users by ID and searching for users.

The Protocol Buffer contracts are located under `contracts/proto/` in the repository.

The gRPC server also enables service reflection. Compatible gRPC clients can use reflection to inspect the available service definitions when permitted by the deployment.

## Request and Response Formats

REST endpoints use HTTP methods and JSON request bodies where appropriate.

A JSON request generally includes the `Content-Type: application/json` header.

Successful responses depend on the endpoint. For example, registration and login return an object containing a `token` field.

Always validate response status codes and response fields rather than assuming every request succeeds.

## Error Handling

REST errors use a JSON response with the following structure:

```
{
  "error": "Human-readable error description",
  "code": 1001
}
```

The numeric code identifies the application error.

The following application error codes are defined in the current implementation:

| Code | Meaning |
| --- | --- |
| `1001` | Invalid API token |
| `1002` | Username already exists |
| `1003` | Email already exists |
| `1004` | Invalid credentials |
| `1005` | Invalid name |
| `1006` | Invalid owner email |
| `5000` | Database error |
| `5001` | Internal application error |

HTTP errors are mapped to status codes as follows:

- `400 Bad Request`: Invalid name or owner email.
- `401 Unauthorized`: Invalid API token or credentials.
- `409 Conflict`: Username or email already exists.
- `500 Internal Server Error`: Database or internal application error.

For gRPC requests, application errors are mapped to appropriate gRPC status codes, including `Unauthenticated`, `AlreadyExists`, `InvalidArgument`, and `Internal`.

Clients should handle errors explicitly and avoid displaying internal database or server details to end users.

## Versioning and Compatibility

The API contract is defined by the current implementation and the Protocol Buffer definitions.

Until a formal versioning policy is introduced, clients should not assume that every endpoint or message will remain backward-compatible across releases.

When integrating with IronBook:

- Pin integrations to a known release or commit when stability is important.
- Review API and Protocol Buffer changes when upgrading.
- Test integrations against the target release before deployment.
- Document breaking changes in the project's changelog.
- Avoid relying on undocumented response fields or implementation details.

## Source Code

The following locations are useful when investigating or extending the API:

- `apps/api/src/views/` — HTTP request handlers.
- `apps/api/src/grpc/` — gRPC service implementations.
- `apps/api/src/services/` — Shared application logic.
- `apps/api/src/db/` — Database access.
- `apps/api/src/errors.rs` — Application error definitions and mappings.
- `apps/api/migrations/` — Database schema migrations.
- `contracts/proto/` — Protocol Buffer contracts.

For the latest behavior, use the source code and Protocol Buffer definitions from the same release as the running server.

The endpoint paths, gRPC service names, and error mappings above are based on the repository's API source.

pastee.dev

+1

## 2. Operations documentation

Suggested file: `apps/home/src/app/docs/operations/page.tsx` or the corresponding page in your documentation system.

Writing

# IronBook Operations Guide

## Overview

This guide describes how to configure, deploy, maintain, and troubleshoot IronBook installations.

IronBook is organized as a multi-application repository. Its components include the Rust API, web application, public project website, Android application, desktop application, and PostgreSQL database.

The operational procedures in this document should be adapted to the infrastructure used for each installation.

## Components and Responsibilities

| Component | Location | Responsibility |
| --- | --- | --- |
| API | `apps/api/` | REST and gRPC endpoints, application logic, and database access. |
| Web application | `apps/web/` | Web-based application interface. |
| Project website | `apps/home/` | Public website and documentation. |
| Android application | `apps/android/` | Android client. |
| Desktop application | `apps/desktop/` | Desktop client. |
| Database | PostgreSQL | Persistent application data. |

## Prerequisites

Before deploying IronBook, prepare the following:

- A supported operating system and the dependencies required by the selected components.
- Git for retrieving the source code.
- mise for managing project tool versions and tasks.
- PostgreSQL for the API's persistent storage.
- Network access between the API and the database.
- Appropriate environment variables and deployment secrets.
- A reverse proxy and TLS configuration if the services will be accessible over a public network.

Check the repository's tool configuration files and component-specific README files for the versions and additional requirements applicable to your release.

## Initial Setup

From the repository root, run:

```
scripts/ironbook.sh setup
```

This command performs the repository's setup procedure.

To set up only the public documentation website, use:

```
mise run //apps/home:setup
```

For API development, consult `apps/api/README.md` and the API-specific tasks in `apps/api/mise.toml`.

Do not deploy a development configuration directly to a public production environment without reviewing its network exposure, secrets, logging, and database settings.

## Environment Variables

IronBook uses environment variables for configuration and secrets.

The repository contains example configuration files. Start by reviewing:

- The root `.env.example`.
- `apps/api/.env.example`.
- The example environment files belonging to the other components you intend to deploy.

### API Configuration

The API configuration includes the following variables:

| Variable | Purpose |
| --- | --- |
| `DATABASE_URL` | Configures access to the PostgreSQL database. |
| `ALLOWED_ORIGINS` | Specifies the allowed HTTP origins for cross-origin requests. |
| `ALLOW_ALL_ORIGINS` | Controls whether the API permits requests from any origin. |

When `ALLOW_ALL_ORIGINS` is enabled, the API allows any origin for the configured HTTP methods. Use this setting cautiously, particularly in production.

When it is disabled, configure `ALLOWED_ORIGINS` with the exact origins that should be allowed.

The API loads environment configuration at startup. Ensure the required variables are present and valid before starting the service.

### Secret Management

- Never commit production credentials, API tokens, passwords, or private keys.
- Use your deployment platform's secret-management facility where available.
- Restrict access to environment files and secret values.
- Rotate credentials when exposure is suspected.
- Use separate credentials for development, testing, and production.
- Avoid printing secrets in application logs, CI output, or diagnostic reports.

Example files document the expected configuration; they should not contain real production secrets.

## Database Management

IronBook uses PostgreSQL and SQLx for database access.

The API includes migrations under `apps/api/migrations/`. These migrations define the database schema, including user, session, and client-related tables.

### Starting the Database

Use the repository's database tasks where supported by your development setup:

```
mise run //apps/api/db:up
```

To stop the development database service:

```
mise run //apps/api/db:down
```

These tasks are intended for the repository's configured development environment. Production database lifecycle management should follow the procedures of the infrastructure provider or database service in use.

### Applying Migrations

Apply pending migrations using:

```
mise run //apps/api/db:migrate
```

The API also runs its embedded SQLx migrations during database initialization.

Before applying schema changes in production:

1. Review the migration files.
2. Back up the database.
3. Verify that the migration is compatible with the deployed application version.
4. Apply the migration using the deployment's approved procedure.
5. Verify application behavior and database health afterward.

Do not edit previously applied migrations in a way that changes their historical meaning. Create a new migration for subsequent schema changes.

## Production Deployment

A production deployment should follow a repeatable process.

### Recommended Deployment Sequence

1. Select the IronBook release or commit to deploy.
2. Review the release notes and any database migration requirements.
3. Provision the required infrastructure and PostgreSQL database.
4. Configure environment variables and secrets.
5. Apply the required database migrations.
6. Build and deploy the API and the other required components.
7. Configure network routing, TLS, and allowed origins.
8. Run health checks and smoke tests.
9. Review logs for startup errors or failed requests.
10. Record the deployed version and deployment outcome.

The exact commands and infrastructure settings depend on the deployment target. Validate the applicable Dockerfiles, component READMEs, and CI/CD workflows before using a procedure in production.

### Network Exposure

The API exposes HTTP endpoints and a gRPC listener. The current gRPC implementation binds to port `50051`.

Only expose the services and ports required by your installation. Prefer a controlled network boundary, with TLS termination and access restrictions configured according to the deployment architecture.

Do not expose PostgreSQL directly to untrusted networks.

## Backups

Maintain regular backups of the PostgreSQL database and any other persistent data required by your deployment.

A backup policy should specify:

- Backup frequency.
- Retention period.
- Storage location.
- Encryption and access controls.
- Responsibility for monitoring backup jobs.
- Recovery objectives and restore testing.

Store backups separately from the primary database infrastructure where practical. A backup that has never been tested should not be assumed to be recoverable.

## Restore Procedures

Before restoring a database:

1. Identify the appropriate backup.
2. Verify the backup's integrity using the available database tooling.
3. Determine whether a full restore or a point-in-time recovery is required and supported by your database provider.
4. Restore into an isolated or otherwise controlled environment when possible.
5. Verify the schema, expected data, and application compatibility.
6. Reconnect the application only after validation.
7. Document the recovery result and any data loss.

The actual restore commands depend on the backup format and PostgreSQL hosting arrangement. Maintain a tested, deployment-specific runbook rather than relying on generic commands alone.

## Monitoring and Health Checks

Monitor the API, database, and deployed clients for operational problems.

At minimum, consider monitoring:

- API availability and response latency.
- HTTP error rates.
- gRPC failures.
- Database connectivity and resource usage.
- Database storage capacity.
- Application restarts and startup failures.
- Backup job success and backup age.
- Disk space and memory usage on self-managed infrastructure.

The API provides a `GET /health` endpoint. Integrate it into your health-check system where appropriate, while recognizing that a basic health response may not establish the health of every dependency.

Configure alerts for sustained failures rather than relying exclusively on manual checks.

## Logging and Troubleshooting

The API uses the Rust tracing ecosystem for application logging.

When investigating a problem:

1. Identify the affected component and deployed version.
2. Check application startup logs.
3. Verify environment configuration without exposing secret values.
4. Check database connectivity and migration status.
5. Inspect relevant HTTP or gRPC error responses.
6. Correlate events using timestamps and any available request context.
7. Reproduce the problem in a controlled environment when possible.

Treat logs as potentially sensitive. Avoid recording passwords, authentication tokens, or unnecessary financial and personal information.

Production logging levels, retention, access controls, and log aggregation should be configured according to operational and privacy requirements.

## Disaster Recovery

Maintain a documented recovery plan for service interruptions, infrastructure failure, accidental data loss, and security incidents.

The plan should identify:

- Critical services and their dependencies.
- Responsible operators and escalation procedures.
- Backup locations and recovery procedures.
- Recovery time and recovery point objectives.
- Procedures for restoring database access.
- Methods for verifying data integrity.
- Communication and incident-recording procedures.

Test the recovery plan periodically and update it after significant architectural or operational changes.

## Releases and Upgrades

IronBook includes a release workflow triggered by version tags matching the repository's configured version pattern.

Before releasing or upgrading:

1. Review the changes included in the release.
2. Run the relevant automated tests.
3. Review migration and compatibility implications.
4. Confirm that required environment variables are documented.
5. Create and verify an appropriate backup.
6. Build and publish the release using the project's established workflow.
7. Deploy the intended version.
8. Perform post-deployment checks.
9. Record the release and any operational issues.

Use the project's release workflow rather than manually improvising release steps. Verify the current workflow configuration before publishing a new release.

## Development and Testing Tasks

The API defines tasks for development, testing, and database management.

| Task | Purpose |
| --- | --- |
| `mise run //apps/api/dev` | Run the API development server with automatic reload. |
| `mise run //apps/api/test` | Run the API unit tests. |
| `mise run //apps/api/test-full` | Run the API test suite, including database integration tests. |
| `mise run //apps/api/db:up` | Start the configured development database service. |
| `mise run //apps/api/db:down` | Stop the configured development database service. |
| `mise run //apps/api/db:migrate` | Apply pending database migrations. |
| `mise run //apps/home:test` | Run the public website's tests. |

Database integration tests require a suitable PostgreSQL test database. Use a disposable database or isolated test environment to avoid modifying production data.

## Operational Checklist

Before considering a deployment ready, verify the following:

- [ ]Required environment variables are configured.
- [ ]Production secrets are stored securely.
- [ ]Database migrations have completed successfully.
- [ ]Database backups are configured and monitored.
- [ ]Network access is restricted to the required services.
- [ ]TLS and allowed-origin settings are appropriate.
- [ ]Health checks and application logs are accessible.
- [ ]Release and rollback procedures are documented.
- [ ]Restore procedures have been tested.
- [ ]Operators know how to investigate failures.

## Further Reading

- `apps/api/README.md`
- `apps/home/README.md`
- `apps/api/migrations/`
- `apps/api/.env.example`
- `apps/api/mise.toml`
- `mise.toml`
- `.github/workflows/release.yml`

Review these files whenever the deployment architecture, environment configuration, or release process changes.

The operational commands and API configuration variables are drawn from the repository's setup files, API README, and configuration.
