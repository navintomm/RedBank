# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- **Emergency Workflow Backend**: Completed Phase 4 backend foundation and integration verification.
  - Designed `V4__Emergency_Request_Module.sql` schema with PostGIS support and audit trails.
  - Implemented core Spring State Machine (`DRAFT` to `COMPLETED`) with `@Version` Optimistic Locking, `TransitionValidators`, and async `Actions`.
  - Built isolated cohesive business services (`MatchingService`, `NotificationService`, `RadiusExpansionService`).
  - Created `EmergencyFacade` orchestrator and Jakarta-validated REST APIs (`EmergencyController`).
  - Implemented full `EmergencyIntegrationTest` suite testing the Database, State Machine, and REST integration.
  - Generated `EmergencySequenceDiagrams` and `EmergencyAPIExamples` for frontend developers.

## [0.5.0] - 2026-07-11
### Added
- **Donor Module Finalization**: Completed frontend-backend integration for Donor Profile creation, updates, and availability status.
- **Environment Stabilization**: Isolated Maven build directory to resolve IDE-Compiler background caching conflicts (Java 17/21).
- **Frontend Refactoring**: Refactored Donor Profile screens to use `SingleChildScrollView` for proper form validation lifecycle.
- **Verification Pipeline**: Integrated automated `mvn verify` and `flutter test` pipelines into release verification strategy.

## [1.0.0] - TBD
### Planned
- **Production Release**: Full platform launch including iOS App Store and Google Play deployments.
- Final security audits, load testing, and stabilization.

## [0.3.0] - TBD
### Planned
- **Emergency Module**: Emergency request creation, status tracking, and notification state machines.
- **Matching Engine**: Core spatial querying and heuristic scoring algorithms.
- **Maps Integration**: Location visualization and boundary expansion logic.

## [0.2.0] - 2026-07-09
### Added
- **Donor Module**: Complete end-to-end Donor Profile management.
  - Database schema (`V3__Donor_Module.sql`) with PostGIS geometries, check constraints, and triggers.
  - Spring Boot backend services for Location, Availability, and Eligibility validation.
  - Flutter frontend Donor Profile Screen, Edit Profile, and Location Picker (Google Maps & Geolocator).
  - Availability Toggle with Cooldown locking logic.
  - Profile Image upload to Cloudinary with cropping and compression.
  - Robust Riverpod state management and comprehensive test suite.
- **Design System**: Centralized Material 3 theming (`app_colors`, `app_spacing`, `app_typography`).

## [0.1.0] - 2026-07-09
### Added
- **Documentation Suite**: Completed 14 architectural documents spanning Vision, DB Design, API Docs, Matching Engine heuristics, Security, and DevOps.
- **Project Bootstrap**: Initialized the Modular Monolith repository structure.
  - Setup Flutter frontend with Riverpod, Dio, and GoRouter.
  - Setup Spring Boot 3.2 backend with Hibernate Spatial and Flyway.
  - Configured PostgreSQL + PostGIS via Docker Compose.
  - Implemented GitHub Actions CI/CD workflows and PR templates.
- **Authentication Module**: Complete end-to-end Firebase Phone Auth integration.
  - Implemented JWT generation, validation, and refresh token rotation on the backend.
  - Configured Spring Security stateless filters.
  - Created initial Flyway database schema (`V2__Auth_Schema.sql`).
  - Implemented Flutter auth state management and secure token storage.
  - Created OTP verification and login UI screens.

[Unreleased]: https://github.com/navintomm/RedBank/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/navintomm/RedBank/compare/v0.3.0...v1.0.0
[0.3.0]: https://github.com/navintomm/RedBank/compare/v0.2.0...v0.3.0
[0.2.0]: https://github.com/navintomm/RedBank/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/navintomm/RedBank/releases/tag/v0.1.0
