# Contributing to Red Bank

First off, thank you for considering contributing to Red Bank! It's people like you that make this platform a powerful tool for saving lives during medical emergencies.

This document serves as a set of guidelines for contributing to the Red Bank repository. These are mostly guidelines, not rules. Use your best judgment, and feel free to propose changes to this document in a pull request.

---

## 🗂 Table of Contents
1. [Proposing New Features](#proposing-new-features)
2. [Issue Workflow](#issue-workflow)
3. [Branch Strategy](#branch-strategy)
4. [Commit Message Format](#commit-message-format)
5. [Pull Request Workflow](#pull-request-workflow)
6. [Review Requirements](#review-requirements)
7. [Coding Standards & Style](#coding-standards--style)
8. [Testing Requirements](#testing-requirements)
9. [Documentation Requirements](#documentation-requirements)

---

## 💡 Proposing New Features
If you have an idea for a new feature, please **do not open a Pull Request immediately**.

1. Check the [Roadmap](13_DevelopmentRoadmap.md) and open issues to see if the feature is already planned.
2. Open a **Feature Request Issue** using the provided GitHub template.
3. Clearly explain the *problem* you are trying to solve and your *proposed solution*.
4. Wait for a core maintainer to approve the architectural design before beginning development. All major features must align with the `03_SystemArchitecture.md` specifications.

---

## 🐞 Issue Workflow
When reporting a bug or requesting a feature:
- Use the official **Bug Report** or **Feature Request** templates.
- Provide as much context as possible (OS, App Version, stack traces).
- If you intend to fix the issue yourself, leave a comment saying `"I would like to work on this"` so a maintainer can assign it to you and prevent duplicated effort.

---

## 🌿 Branch Strategy
We follow a strict trunk-based development workflow.

- **`main`**: Production-ready code only.
- **`staging`**: QA environment branch.
- **Feature Branches**: Must branch off `main` and use the following naming convention:
  - `feat/<issue-id>-short-description` (e.g., `feat/12-add-trust-score`)
  - `fix/<issue-id>-short-description` (e.g., `fix/34-resolve-jwt-expiry`)
  - `docs/<issue-id>-short-description`
  - `refactor/<issue-id>-short-description`

---

## 📝 Commit Message Format
We enforce the [Conventional Commits](https://www.conventionalcommits.org/) standard. This allows us to auto-generate changelogs.

**Format:**
```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat:` A new feature
- `fix:` A bug fix
- `docs:` Documentation only changes
- `style:` Changes that do not affect the meaning of the code (white-space, formatting)
- `refactor:` A code change that neither fixes a bug nor adds a feature
- `test:` Adding missing tests or correcting existing tests
- `chore:` Changes to the build process or auxiliary tools

**Example:**
`feat(auth): integrate firebase OTP verification`

---

## 🔄 Pull Request Workflow
1. Ensure your code is fully synced with the latest `main` branch.
2. Push your branch to your fork.
3. Open a Pull Request against the `main` branch.
4. Fill out the **Pull Request Template** completely.
5. Link the PR to the relevant issue (e.g., `Fixes #12`).
6. Ensure all GitHub Actions CI checks are passing.

---

## 🧐 Review Requirements
A Pull Request cannot be merged until it meets the following criteria:
- **1 Approval** from a core maintainer.
- **CI/CD Passing**: All Spring Boot and Flutter unit tests must pass.
- **No unresolved comments**: All review feedback must be addressed.

---

## 💻 Coding Standards & Style

### General
- Follow the **SOLID** principles and **Clean Architecture**.
- Keep it simple (KISS). Avoid over-engineering.
- **Don't Repeat Yourself (DRY)**.

### Java (Spring Boot)
- **Dependency Injection**: Use Constructor Injection exclusively. Never use `@Autowired` field injection.
- **Data Transfer**: Never expose JPA Entities directly via REST controllers. Always use DTOs and `MapStruct` mappers.
- **Immutability**: Use Java `record` classes for DTOs where possible.
- **Formatting**: Follow standard Google Java Style. The `.editorconfig` will enforce 4-space indentation.

### Dart (Flutter)
- **State Management**: Use `flutter_riverpod` exclusively.
- **Formatting**: Use `flutter format` (2-space indentation).
- Follow all linting rules defined in `analysis_options.yaml` (e.g., `prefer_const_constructors`).

---

## 🧪 Testing Requirements
Red Bank is a critical medical logistics platform. We maintain a **Zero-Defect Tolerance** policy.

- **Backend**: Any new service method must be accompanied by JUnit/Mockito tests.
- **Frontend**: Complex UI logic and StateNotifiers must have widget or unit tests.
- **Coverage**: Your PR should not drop the overall test coverage below 85%.

---

## 📚 Documentation Requirements
- **JavaDoc**: Document complex algorithmic logic (especially within the Matching Engine).
- **Swagger/OpenAPI**: Any new REST Controller endpoint must be annotated with `@Operation` and `@ApiResponses`.
- **Architectural Changes**: If your PR modifies how a core system behaves, you must update the relevant markdown file in the `/docs` directory (e.g., `09_MatchingEngine.md`) in the same PR.

---

Thank you for contributing to Red Bank! 🩸
