---
name: verify-feature-map
description: Audit or maintain an existing app verification feature map against source and live user journeys. Use for feature-map drift or a requested verification coverage audit.
---

# Verify a feature map

Use the project's existing verification or run skill and feature map. This adds coverage reconciliation to the host's app-launch tools. It does not generate another launch framework.

1. Locate the map and its driving instructions. Default to the features named in the request or affected by the change. Exercise every mapped feature only for a requested full audit. If no map exists, report that; create one only when asked, using the existing run tooling.
2. Check the index against feature files. For each in-scope journey, inspect the source entrypoint, prerequisites, user actions, observable result, and documented gotchas. Prefer one targeted source pass over a worker per file.
3. Drive those journeys on the real user interface. Confirm readiness, build identity, authentication, and necessary seed state first. Capture the action, resulting state, and relevant side effects. Do not substitute internal setters for the actual journey.
4. Separate documentation drift, a driving-tool gap, a product regression, and an unavailable prerequisite. Fix the map or its owned helpers within scope. Report product bugs without changing product code or weakening expectations to match them.
5. Rerun journeys affected by a helper change. Clean up instances and temporary state you created, including failed attempts. Preserve captured evidence outside cleanup targets. Reset a surprising or unhealthy session before continuing.

Report covered, failed, and blocked journeys, corrections made, and remaining gaps. A source-only review is not live coverage. Do not create a PR, schedule maintenance, or generate one file per feature unless requested.

## Shared verification artifacts

Treat existing generated verification skills, including pstack output, as a shared project contract. Preserve names, locations, section structure, property or journey meaning, and coverage records during routine maintenance. Correct proven drift in place; retain usable commands and dependencies for the project's supported environments. Rename, relocate, replace the framework, or change the contract only when requested. Do not introduce a dependency on ostack merely to maintain an existing artifact. Report an unsupported tool or discovery path rather than silently migrating it.
