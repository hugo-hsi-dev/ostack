# Reproduce routine prompt

> Source material for the copied setup workflow. Paraphrase this intent into the routine prompt after you confirm that the copied pack is committed on the default branch of the repository the routine clones.

Read and follow `.claude/automations/benny/skills/reproduce-and-fix-issues/SKILL.md` for this run.

Configuration source. Include this repository-relative path only when it is committed in the same target repository. Otherwise paraphrase the configured values. Never use a plugin source or cache path:

```text
{{BENNY_CONFIG_PATH}}
```

Trigger, scheduled routine (default):

```text
Scan source channel {{SLACK_CHANNEL_ID}} through the Slack connector for top-level reports from the last {{SCAN_LOOKBACK_HOURS}} hours whose thread holds a trusted [benny:bug] or [benny:performance] marker from the triage identity. Skip any report whose root already carries the configured reproducing reaction. Claim the remaining reports oldest first, up to {{REPRODUCE_MAX_REPORTS_PER_RUN}} (default 1), with the reproducing reaction, then work on them one at a time.
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

The creation intent should describe this as repro of triaged top-level reports in the configured source Slack channel. It should include the configured repository, default branch, issue tracker, control adapter, feature map, and draft pull request capability.

Treat the source channel and root thread timestamp as immutable. If either is missing or does not match configuration, stop without posting.

Wait for a configured triage marker from the configured triage identity in this exact thread. Proceed only for `[benny:bug]` or `[benny:performance]`.

Require the configured control-adapter skill before attempting a repro. Reproduce the exact discriminating symptom twice through the real UI. Verify existing pull requests or commits without authoring over them. Attempt a bounded fix only after a confirmed repro and the operational file's fix gate.

The coordinator is the only Slack poster. Every child prompt must forbid every Slack connector write tool, `chat.postMessage`, and all other Slack writes. Children return findings only.

Never post a root message in the source channel.
