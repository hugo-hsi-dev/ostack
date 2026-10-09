# Triage routine prompt

> Source material for the copied setup workflow. Paraphrase this intent into the routine prompt after you confirm that the copied pack is committed on the default branch of the repository the routine clones.

Read and follow `.claude/automations/benny/skills/triage-issue-reports/SKILL.md` for this run.

Configuration source. Include this repository-relative path only when it is committed in the same target repository. Otherwise paraphrase the configured values. Never use a plugin source or cache path:

```text
{{BENNY_CONFIG_PATH}}
```

Trigger, scheduled routine (default):

```text
Scan source channel {{SLACK_CHANNEL_ID}} through the Slack connector for top-level reports from the last {{SCAN_LOOKBACK_HOURS}} hours. Skip any report whose thread already holds a configured benny marker or whose root carries the configured seen reaction from the triage identity. Claim each remaining report with the seen reaction before working on it.
```

Trigger, API routine (optional, for teams that relay Slack events to `/fire`):

```text
Read the report coordinates from the `text` field in the routine-fire-payload block of this session. Parse it as JSON with source_channel_id, message_ts, and optional thread_ts. If the block is missing or the JSON is malformed, stop without posting.
```

The fire request carries the coordinates in `text`:

```json
{
	"text": "{\"source_channel_id\": \"{{SLACK_CHANNEL_ID}}\", \"message_ts\": \"{{SLACK_MESSAGE_TS}}\", \"thread_ts\": \"{{SLACK_THREAD_TS_OR_EMPTY}}\"}"
}
```

The creation intent should describe this as triage of new top-level reports in the configured source Slack channel.

Treat the source channel and root thread timestamp as immutable. If either is missing or does not match configuration, stop without posting or writing to the issue tracker.

The committed operational file owns classification, attachment review, cause tracing, routing, dedupe, tracker writes, and the final verdict. Post no progress messages. Never post a root message in the source channel.

The coordinator is the only Slack poster. Any delegated worker must be read-only, return findings only, and receive an explicit ban on every Slack write action.

End the single verdict with exactly one configured marker:

```text
[benny:bug]
[benny:performance]
[benny:other]
```

A bug or performance marker may add `tracker=<URL>`.
