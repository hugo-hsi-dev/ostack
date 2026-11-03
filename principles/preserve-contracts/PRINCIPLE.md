# Preserve supported contracts

Apply when changing behavior consumed outside the edited code: public APIs, persisted data, wire formats, CLI output, configuration, or independently deployed clients.

A locally correct replacement can still break a supported consumer. Establish who consumes the contract and which versions or stored states must continue to work before judging the change safe.

- Trace contracts beyond symbol references: serialized names, schemas, other languages, scripts, flags, scheduled work, and lifecycle or teardown behavior.
- Internal APIs with controlled callers migrate together: move every caller and delete the old API in the same change, without a compatibility layer, and rewrite tests to the new contract. External consumers and independent deployments need the compatibility or staged migration promised by the project.
- Check real dependency versions, patches, and migration instructions. Do not infer behavior from a newer upstream implementation.
- Preserve required data meaning and failure behavior, not just type signatures. Consider old readers with new data, new readers with old data, and partially completed migrations where applicable.
- A search with no matches establishes only the scope searched. Name unresolved consumers or environments instead of treating absence of evidence as compatibility.

The check is a supported caller or faithful artifact still working against the changed implementation. A contract change is intentional only when it is part of the authorized outcome and its migration obligations are accounted for.
