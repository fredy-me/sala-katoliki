# Contributing to Sala Katoliki

Thank you for your interest in contributing to Sala Katoliki. This document provides strict guidelines and requirements for all contributions. Every contributor must read and follow these rules completely.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Mandatory Issue Requirement](#mandatory-issue-requirement)
- [Types of Contributions](#types-of-contributions)
- [Development Setup](#development-setup)
- [Branch Naming Convention](#branch-naming-convention)
- [Commit Message Convention](#commit-message-convention)
- [Code Style Guide](#code-style-guide)
- [Content Guidelines](#content-guidelines)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Prohibited Contributions](#prohibited-contributions)
- [Questions and Contact](#questions-and-contact)

---

## Code of Conduct

This project follows our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Report unacceptable behavior to the project maintainers.

---

## Mandatory Issue Requirement

**ALL changes require an approved issue before any work begins. No exceptions.**

This applies to:

- Bug fixes
- New features
- Documentation changes
- Content additions (prayers, novenas, rosary)
- Translation work
- Code refactoring
- Any other modification

### Workflow

1. **Open an issue** describing the change you want to make
2. **Wait for maintainer approval** before starting work
3. **Get assigned** to the issue
4. **Create a branch** from the approved issue
5. **Submit a pull request** referencing the approved issue

Pull requests without a corresponding approved issue will be closed immediately.

---

## Types of Contributions

### Reporting Bugs

Use the [Bug Report template](.github/ISSUE_TEMPLATE/bug_report.md). Include:

- Clear description of the bug
- Steps to reproduce
- Expected behavior vs actual behavior
- Device/OS/Flutter version
- Screenshots if applicable

### Suggesting Features

Use the [Feature Request template](.github/ISSUE_TEMPLATE/feature_request.md). Include:

- Problem statement
- Proposed solution
- Alternatives considered
- Alignment with MVP scope

### Adding Prayer Content

Use the [Content Request template](.github/ISSUE_TEMPLATE/content_request.md). Include:

- Prayer type and category
- Language (English/Kiswahili)
- Source and licensing rights
- JSON content draft

### Improving Documentation

Documentation improvements are welcome. Follow the same issue-first process.

### Translations

Translation contributions must follow the [Translation Guidelines](docs/content_guidelines/translation_guidelines.md).

---

## Development Setup

### Prerequisites

- Flutter SDK ^3.10.4
- Dart SDK ^3.10.4
- Git
- Android Studio or VS Code with Flutter extension
- Physical Android device or emulator (API level 24+)

### Setup Steps

1. **Fork the repository** on GitHub

2. **Clone your fork:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/salakatoliki.git
   cd salakatoliki
   ```

3. **Add upstream remote:**
   ```bash
   git remote add upstream https://github.com/ORIGINAL_OWNER/salakatoliki.git
   ```

4. **Install dependencies:**
   ```bash
   flutter pub get
   ```

5. **Verify setup:**
   ```bash
   flutter analyze
   flutter test
   dart run tools/validate_content.dart
   ```

6. **Run the app:**
   ```bash
   flutter run
   ```

All three verification commands must pass before you begin any work.

---

## Branch Naming Convention

All branches must follow this format:

```
type/issue-number-description
```

### Branch Types

| Type | Purpose | Example |
|------|---------|---------|
| `feat/` | New feature | `feat/42-add-prayer-search` |
| `fix/` | Bug fix | `fix/15-novena-progress-reset` |
| `docs/` | Documentation | `docs/38-update-architecture` |
| `content/` | Prayer/novena/rosary content | `content/51-add-st-jude-novena` |
| `refactor/` | Code restructuring | `refactor/29-extract-notification` |
| `test/` | Test additions | `test/33-rosary-widget-tests` |
| `chore/` | Maintenance tasks | `chore/45-update-dependencies` |

### Rules

- Lowercase only
- Hyphens for spaces
- Issue number must be included
- Description must be concise (max 50 characters after the issue number)
- Never work on `main` directly

---

## Commit Message Convention

All commits must follow [Conventional Commits](https://www.conventionalcommits.org/).

### Format

```
type(scope): description

[optional body]

[optional footer(s)]
```

### Types

| Type | Description |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `content` | Prayer/novena/rosary content addition |
| `style` | Formatting, missing semicolons, etc. |
| `refactor` | Code change that neither fixes a bug nor adds a feature |
| `test` | Adding or updating tests |
| `chore` | Maintenance tasks, dependency updates |

### Scopes

| Scope | Area |
|-------|------|
| `onboarding` | Language selection |
| `today` | Today screen |
| `prayers` | Prayer library, detail, search |
| `rosary` | Interactive Rosary |
| `novenas` | Novena progress |
| `settings` | Settings and preferences |
| `favorites` | Favorites feature |
| `notifications` | Local notifications |
| `content` | Bundled JSON content |
| `theme` | App theme and styling |
| `localization` | Language support |
| `routing` | Navigation and routes |

### Examples

```
feat(prayers): add offline search scoring

fix(novena): reset progress on novena completion

content(rosary): add Joyful Mysteries for Kiswahili

docs(architecture): update data models section

test(favorites): add persistence tests
```

### Rules

- Subject line max 72 characters
- Use imperative mood ("add" not "added")
- No period at end of subject
- Body max 72 characters per line
- Reference issue in footer: `Closes #42`

---

## Code Style Guide

### Dart/Flutter Conventions

- Follow official [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` with zero issues
- Follow existing code patterns in the file you are editing
- Use meaningful variable and function names
- Add doc comments for public APIs

### Architecture Rules

The app follows clean architecture with strict separation:

```
lib/
  features/     # Presentation (screens, widgets, providers)
  data/         # Models, repositories, datasources
  core/         # Theme, constants, utils, localization
  shared/       # Reusable widgets and services
```

**Rules:**

- Feature code goes in `lib/features/your_feature/`
- Never put business logic in widgets
- Never put UI code in data layer
- Use Riverpod providers for state management
- Follow existing file naming patterns

### Critical Rule: No Hard-Coded Prayer Text

**NEVER put prayer text directly in Flutter screens.**

Wrong:
```dart
Text("Hail Mary, full of grace...")
```

Correct:
```dart
Text(prayerEntity.body)
```

All prayer content must come from bundled JSON files under `assets/content/`.

### Pre-Commit Checks

Run these before committing:

```bash
flutter analyze
flutter test
dart run tools/validate_content.dart
```

All three must pass with zero errors.

---

## Content Guidelines

### JSON Schema Requirements

All prayer content must follow the schemas defined in [Content Guide](docs/CONTENT_GUIDE.md).

Required prayer fields:
- `id` (lowercase snake_case, unique)
- `type` (usually "prayer")
- `category` (must reference existing category)
- `language` ("en" or "sw")
- `title`
- `body`

### Adding New Content

1. Open a content request issue
2. Get maintainer approval
3. Add JSON files to appropriate `assets/content/` directory
4. Register new assets in `pubspec.yaml` if needed
5. Run content validator: `dart run tools/validate_content.dart`
6. Submit PR with validated content

### Translation Rules

- Follow [Translation Guidelines](docs/content_guidelines/translation_guidelines.md)
- English and Kiswahili only for MVP
- Both languages must be present for every prayer
- Translation accuracy is the contributor's responsibility

### Content Rights

- Follow [Content Rights guidelines](docs/content_guidelines/content_rights.md)
- All content must be public domain or properly licensed
- Include `source` field for attribution
- No copyrighted material without written permission

---

## Testing Requirements

### Test Types

| Type | Location | Required |
|------|----------|----------|
| Unit tests | `test/unit/` | For all new logic |
| Widget tests | `test/widget/` | For all new UI |
| Integration tests | `integration_test/` | For critical flows |
| Content validation | `tools/validate_content.dart` | For all content changes |

### Test Requirements

- All new features must include tests
- Bug fixes must include regression tests
- All existing tests must continue to pass
- Tests must be deterministic (no flaky tests)
- Run full test suite before submitting PR

### Running Tests

```bash
# Unit and widget tests
flutter test

# Integration tests (requires device/emulator)
flutter test integration_test/

# Content validation
dart run tools/validate_content.dart
```

---

## Pull Request Process

### Before Submitting

- [ ] Issue exists and is approved
- [ ] You are assigned to the issue
- [ ] Branch follows naming convention
- [ ] Code follows style guide
- [ ] `flutter analyze` passes with zero issues
- [ ] `flutter test` passes
- [ ] `dart run tools/validate_content.dart` passes (if content changes)
- [ ] Documentation is updated (if applicable)
- [ ] Commit messages follow convention
- [ ] PR references the issue: `Closes #issue-number`

### PR Description

Use the [Pull Request template](.github/PULL_REQUEST_TEMPLATE.md). Include:

- Description of changes
- Related issue number
- Type of change
- Testing performed
- Checklist completion

### Review Process

1. PR is submitted with all checks passing
2. Maintainer reviews within 7 days
3. Changes may be requested
4. Address all review comments
5. Maintainer approves and merges

### Merge Strategy

- **Squash merge** is the default strategy
- PR title becomes the commit message
- Individual commits are squashed into one
- Branch is deleted after merge

### After Merge

- Pull latest main
- Delete your feature branch
- Update issue status
- Celebrate your contribution

---

## Prohibited Contributions

The following are **NOT allowed** in the MVP:

### Out-of-Scope Features

- Authentication, registration, profiles, or social sign-in
- Backend CMS, admin dashboard, or cloud sync
- Payments, donations, subscriptions, or ads
- Audio, video, podcasts, or guided meditation
- Full Bible, full Catechism, or Mass booking
- Community posting, chat, or comments
- AI spiritual advisor or pastoral automation
- Parish management or sacrament scheduling

### Prohibited Content

- Copyrighted Bible translations without permission
- Mass readings without proper licensing
- Devotional material without written permission
- Any content with restrictive licenses

### Prohibited Code Changes

- Breaking MVP scope without maintainer approval
- Adding new dependencies without discussion
- Modifying architecture without approved issue
- Hard-coding prayer text in widgets
- Requesting unnecessary permissions

---

## Questions and Contact

For questions about contributing:

1. Check existing documentation in `docs/`
2. Search existing issues for answers
3. Open a discussion issue if needed

For urgent matters, contact the project maintainers directly.

---

## Summary

| Rule | Requirement |
|------|-------------|
| Issue first | ALL changes need approved issue |
| Branch naming | `type/issue-number-description` |
| Commits | Conventional Commits format |
| Code style | Zero `flutter analyze` issues |
| Tests | All tests must pass |
| Content | Must pass content validator |
| PR template | Fully completed |
| Review | Wait for maintainer approval |
| Scope | MVP only, no out-of-scope work |

**Thank you for following these guidelines and contributing to Sala Katoliki.**
