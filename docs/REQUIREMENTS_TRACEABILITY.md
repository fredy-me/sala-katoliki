# Requirements Traceability

This file maps the MVP SRS requirements to implementation areas and acceptance checks.

## Functional Requirements

| ID | Requirement | Implementation Area | Acceptance Check |
| --- | --- | --- | --- |
| FR-001 | Language selection | Onboarding, Settings, local preferences, localization | User selects English or Kiswahili, can change it later, and selection persists after restart. |
| FR-002 | Today screen | Today feature, shortcuts, active progress summaries | User can reach prayer or Rosary within two taps. |
| FR-003 | Prayer categories | Category JSON, content repository, Pray tab | Categories render from JSON without one screen per category. |
| FR-004 | Prayer list | Prayer repository, category filtering, language filtering | User opens a category and sees prayers in selected language. |
| FR-005 | Prayer detail | Prayer detail screen, source metadata, favorite state | Prayer is readable offline and can be favorited. |
| FR-006 | Common prayer content | Bundled prayer JSON | Agreed common prayers are bundled in English and priority Kiswahili translations. |
| FR-007 | Favorites | Local storage, favorites feature | Favorite state persists after restart. |
| FR-008 | Search | Offline search index over title, body, tags, category | Search works offline and handles empty/no-match states. |
| FR-009 | Interactive Rosary | Rosary content, mystery rules, progress storage | User can start, continue, navigate, and restart Rosary offline. |
| FR-010 | Novenas | Novena content, progress storage, Today continuation | User can complete Day 1-Day 9 and continue from Today. |
| FR-011 | Daily reminder | Local notification service, Settings | User can enable, change, and disable reminder. |
| FR-012 | Offline mode | Bundled content, local storage, no backend dependency | Airplane-mode regression passes for core MVP features. |
| FR-013 | Settings | Settings feature and local preferences | Language, font size, theme, and reminder settings persist. |
| FR-014 | Content attribution | About screen, prayer source metadata | About includes content, license, and source notes. |
| FR-015 | Content extensibility | Content loader and validation | New valid prayer JSON appears without new UI screen. |

## Non-Functional Requirements

| Area | Requirement | Verification |
| --- | --- | --- |
| Performance | Fast startup, prayer detail, and search | Manual timing and performance profiling on representative Android device. |
| Reliability | Corrupt progress must not crash app | Unit tests for bad local progress data and exploratory QA. |
| Offline reliability | Core features work without internet | Airplane-mode regression test. |
| Security/privacy | No auth, no sensitive data collection, minimal permissions | Manifest and iOS permission review. |
| Maintainability | Separate UI, domain, content loading, and storage | Code review and architecture checks. |
| Portability | Android/iOS Flutter codebase with isolated platform services | Android and iOS build checks when iOS release is in scope. |
| Mobile lifecycle | Save Rosary/novena progress on backgrounding | Manual lifecycle QA and widget/unit tests where practical. |
| Store readiness | Support link, privacy policy, content attribution, target SDK compliance | Release checklist before store submission. |

## Business Requirement Mapping

| Business Requirement | Functional Requirements | Test Area |
| --- | --- | --- |
| BR-001 Help users pray daily | FR-002, FR-005, FR-006, FR-011 | Today, prayer detail, reminder tests. |
| BR-002 Provide essential Catholic prayers | FR-003, FR-004, FR-005, FR-006 | Category and prayer content tests. |
| BR-003 Support Rosary devotion | FR-009 | Rosary workflow tests. |
| BR-004 Support novena habit and retention | FR-010, FR-011 | Novena progress and reminder tests. |
| BR-005 Work offline | FR-012 | Airplane-mode regression tests. |
| BR-006 Support English and Kiswahili | FR-001, FR-003, FR-006, FR-013 | Localization tests. |
| BR-007 Enable quick access to preferred prayers | FR-007, FR-008 | Favorites and search tests. |
| BR-008 Enable future prayer additions without screen hardcoding | FR-015 | Content schema validation and dynamic rendering test. |
| BR-009 Avoid unnecessary user data collection | FR-013 and security NFRs | Permission and privacy review. |
| BR-010 Prepare for app store release | FR-014 and compliance NFRs | Store checklist and policy review. |
