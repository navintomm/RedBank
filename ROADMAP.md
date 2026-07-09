# Red Bank Development Roadmap

This document outlines the strategic implementation phases for the Red Bank platform. It provides a high-level overview of what has been accomplished, what is currently in progress, and the long-term vision for future scalability.

For a highly detailed architectural breakdown of each phase, refer to the [Development Roadmap Specification](docs/13_DevelopmentRoadmap.md) (Note: Assuming documents are in the `/docs` folder per the implementation plan).

---

## ✅ Completed (Phase 1 & 2)

The foundational architecture and project skeleton have been successfully established.

- [x] **Documentation Suite**: Completion and approval of all 14 core architectural specifications (Vision, Database, Architecture, UI/UX, Matching Engine, Security, DevOps, etc.).
- [x] **Project Bootstrap**: 
  - Initialization of the Flutter (Frontend) and Spring Boot 3 (Backend) repositories.
  - Setup of PostgreSQL + PostGIS via Docker Compose.
  - CI/CD workflow configuration via GitHub Actions.
- [x] **Authentication Module**:
  - Integration of Firebase Phone Authentication.
  - Stateless Spring Security custom JWT implementation.
  - Refresh token rotation and logout functionality.

---

## 🚧 Current (Phase 3)

We are currently executing the core user provisioning flow.

- [ ] **Donor Module**:
  - Donor onboarding and KYC data collection.
  - Biological data tracking (Blood Type, Weight, Last Donation Date).
  - Availability toggles and geographic location updates.
  - Base Trust Score implementation.

---

## 🗓 Upcoming (Phase 4 - 8)

The following modules will complete the Minimum Viable Product (MVP) leading to the v1.0.0 release.

### Emergency & Dispatch
- [ ] **Emergency Requests**: Patient data ingestion, emergency severity classification, and active request tracking.
- [ ] **Matching Engine**: Deterministic spatial querying (`ST_DWithin`), blood type compatibility filtering, and heuristic ranking.

### Operations & UX
- [ ] **Notifications**: Firebase Cloud Messaging (FCM) integration for instant donor pinging.
- [ ] **Maps Integration**: Google Maps SDK rendering for live donor routing and visual emergency radius plotting.
- [ ] **Admin Dashboard**: Centralized oversight for manual KYC verification and system health metrics.

### Quality Assurance & Release
- [ ] **Testing**: Comprehensive CI/CD integration, end-to-end (E2E) UI testing, and API load testing.
- [ ] **Deployment**: Production deployment to Railway/Render (PaaS) and Neon (Serverless PostgreSQL).
- [ ] **Version 1.0 Release**: Final stabilization and app store submission.

---

## 🚀 Future (Version 2.0+)

Post-MVP, Red Bank will evolve into an enterprise-scale logistics network connecting individual donors directly with institutional healthcare providers.

- [ ] **Hospital Portal**: Direct B2B API integration and webhook support for hospital inventory systems.
- [ ] **Blood Bank Portal**: Live blood bank inventory tracking and aggregated shortage alerts.
- [ ] **Volunteer Portal**: Tools for NGOs to manage mass blood donation drives and track volunteer contributions.
- [ ] **AI Predictive Matching**: Machine learning algorithms to predict donor acceptance probabilities based on historical behavior and time-of-day metrics.
- [ ] **Advanced Analytics**: Big data visualization for regional blood shortage trends and response time analytics.
