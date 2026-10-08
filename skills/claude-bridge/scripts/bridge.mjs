#!/usr/bin/env node
// Claude bridge registry and fire helper. Node 18+, no dependencies.
// The unit is a Project package: one Claude Project, its cloud environment, and
// the bridge into it (relay routine, coordinator, Grok Bot webhook routine).
// Registry root: $CLAUDE_BRIDGE_HOME, default /workspace/claude-bridge.
// Each package lives in <root>/<project-slug>/project.json and threads.jsonl.

import { mkdirSync, readFileSync, writeFileSync, renameSync, appendFileSync, readdirSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = process.env.CLAUDE_BRIDGE_HOME || "/workspace/claude-bridge";
const REFERENCES = join(dirname(fileURLToPath(import.meta.url)), "..", "references");
const SLUG_RE = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;

function fail(message) {
  process.stderr.write(`bridge: ${message}\n`);
  process.exit(1);
}

function parseArgs(argv) {
  const [command, ...rest] = argv;
  const flags = {};
  for (let i = 0; i < rest.length; i++) {
    const arg = rest[i];
    if (!arg.startsWith("--")) fail(`unexpected argument: ${arg}`);
    const key = arg.slice(2);
    const next = rest[i + 1];
    if (next === undefined || next.startsWith("--")) flags[key] = true;
    else { flags[key] = next; i++; }
  }
  return { command, flags };
}

function need(flags, key) {
  const value = flags[key];
  if (typeof value !== "string" || value === "") fail(`--${key} is required`);
  return value;
}

function envPrefix(slug) {
  return `CLAUDE_BRIDGE_${slug.toUpperCase().replace(/-/g, "_")}`;
}

function bridgeDir(slug) {
  if (!SLUG_RE.test(slug)) fail(`invalid Project slug "${slug}": use lowercase letters, digits, and single hyphens`);
  return join(ROOT, slug);
}

function readBridge(slug) {
  const file = join(bridgeDir(slug), "project.json");
  if (!existsSync(file)) fail(`no Project package "${slug}" in ${ROOT}`);
  return JSON.parse(readFileSync(file, "utf8"));
}

function writeBridge(bridge) {
  const file = join(bridgeDir(bridge.slug), "project.json");
  const tmp = `${file}.${process.pid}.tmp`;
  writeFileSync(tmp, JSON.stringify(bridge, null, 2) + "\n");
  renameSync(tmp, file);
}

function requireOwner(bridge, agentId) {
  if (bridge.owner.agent_id !== agentId) {
    fail(`Project package "${bridge.slug}" belongs to ${bridge.owner.name} (${bridge.owner.agent_id}), not ${agentId}. Only the owning bot may change or fire it.`);
  }
}

function logThread(slug, entry) {
  appendFileSync(join(bridgeDir(slug), "threads.jsonl"), JSON.stringify({ at: new Date().toISOString(), ...entry }) + "\n");
}

function readStdinJson() {
  let text;
  try { text = readFileSync(0, "utf8"); } catch { fail("expected a JSON object on stdin"); }
  try { return JSON.parse(text); } catch { fail("stdin is not valid JSON"); }
}

function timestamp() {
  const d = new Date();
  const p = (n) => String(n).padStart(2, "0");
  return `${d.getFullYear()}${p(d.getMonth() + 1)}${p(d.getDate())}-${p(d.getHours())}${p(d.getMinutes())}${p(d.getSeconds())}`;
}

function str(value) {
  return typeof value === "string" && value !== "" ? value : null;
}

function claim(flags) {
  const slug = need(flags, "slug");
  const dir = bridgeDir(slug);
  mkdirSync(ROOT, { recursive: true });
  try {
    mkdirSync(dir);
  } catch (error) {
    if (error.code === "EEXIST") {
      const file = join(dir, "project.json");
      const owner = existsSync(file) ? JSON.parse(readFileSync(file, "utf8")).owner : null;
      fail(`Project slug "${slug}" is taken${owner ? ` by ${owner.name} (${owner.agent_id})` : ""}. Use that package through its owner, or pick another slug.`);
    }
    throw error;
  }
  const mode = flags.mode || "coordinator";
  if (!["coordinator", "direct"].includes(mode)) fail("--mode must be coordinator or direct");
  const prefix = envPrefix(slug);
  const bridge = {
    version: 2,
    slug,
    claude_project: need(flags, "project"),
    owner: { name: need(flags, "owner-name"), agent_id: need(flags, "owner-id") },
    approver: need(flags, "approver"),
    repo: need(flags, "repo"),
    environment: str(flags.environment) || `${slug}-env`,
    mode,
    relay_routine: str(flags["relay-routine"]) || `${slug}-relay`,
    coordinator_session_id: str(flags.coordinator),
    coordinator_updated_at: str(flags.coordinator) ? new Date().toISOString() : null,
    webhook_routine: need(flags, "webhook-routine"),
    webhook_url: str(flags["webhook-url"]),
    env: { fire_url: `${prefix}_FIRE_URL`, token: `${prefix}_TOKEN` },
    created_at: new Date().toISOString(),
  };
  writeBridge(bridge);
  writeFileSync(join(dir, "threads.jsonl"), "", { flag: "a" });
  process.stdout.write(JSON.stringify(bridge, null, 2) + "\n");
}

function show(flags) {
  if (typeof flags.slug === "string") {
    process.stdout.write(JSON.stringify(readBridge(flags.slug), null, 2) + "\n");
    return;
  }
  if (!existsSync(ROOT)) return;
  for (const name of readdirSync(ROOT).sort()) {
    const file = join(ROOT, name, "project.json");
    if (!existsSync(file)) continue;
    const b = JSON.parse(readFileSync(file, "utf8"));
    process.stdout.write(`${b.slug}\tproject=${b.claude_project}\towner=${b.owner.name} (${b.owner.agent_id})\tenvironment=${b.environment}\trepo=${b.repo}\tmode=${b.mode}\n`);
  }
}

function update(flags) {
  const bridge = readBridge(need(flags, "slug"));
  requireOwner(bridge, need(flags, "as"));
  if (typeof flags.coordinator === "string") {
    bridge.coordinator_session_id = flags.coordinator;
    bridge.coordinator_updated_at = new Date().toISOString();
    logThread(bridge.slug, { thread_id: "none", event: "coordinator_updated", coordinator_session_id: flags.coordinator });
  }
  if (typeof flags["new-owner-id"] === "string") {
    bridge.owner = { name: need(flags, "new-owner-name"), agent_id: flags["new-owner-id"] };
  }
  const fields = { repo: "repo", project: "claude_project", approver: "approver", environment: "environment", "relay-routine": "relay_routine", "webhook-routine": "webhook_routine", "webhook-url": "webhook_url", mode: "mode" };
  for (const [flag, field] of Object.entries(fields)) {
    if (typeof flags[flag] === "string") bridge[field] = flags[flag];
  }
  writeBridge(bridge);
  process.stdout.write(JSON.stringify(bridge, null, 2) + "\n");
}

async function fire(flags) {
  const bridge = readBridge(need(flags, "slug"));
  requireOwner(bridge, need(flags, "as"));
  const input = readStdinJson();
  if (typeof input.task !== "string" || input.task === "") fail('stdin needs a non-empty "task"');
  const name = String(input.name || "task").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "").slice(0, 32) || "task";
  const threadId = input.thread_id || `${bridge.slug}:${name}-${timestamp()}`;
  const payload = {
    bridge: bridge.slug,
    from: bridge.owner.name,
    thread_id: threadId,
    task: input.task,
    context: input.context || "",
    reply_expected: input.reply_expected !== false,
  };
  if (bridge.mode === "coordinator") {
    if (!bridge.coordinator_session_id) fail("no coordinator_session_id recorded. Get it from the coordinator and run update --coordinator.");
    payload.coordinator_session_id = bridge.coordinator_session_id;
  }
  const text = JSON.stringify(payload);
  if (text.length > 65536) fail(`payload is ${text.length} characters; the limit is 65,536`);
  if (flags["dry-run"]) { process.stdout.write(text + "\n"); return; }
  const fireUrl = process.env[bridge.env.fire_url];
  const token = process.env[bridge.env.token];
  if (!fireUrl || !token) fail(`missing secret ${!fireUrl ? bridge.env.fire_url : bridge.env.token}. Request it from the user with a secret-request.`);

  const response = await fetch(fireUrl, {
    method: "POST",
    headers: { Authorization: `Bearer ${token}`, "anthropic-version": "2023-06-01", "Content-Type": "application/json" },
    body: JSON.stringify({ text }),
    signal: AbortSignal.timeout(20000),
  });
  const body = await response.text();
  if (!response.ok) {
    const retry = response.headers.get("retry-after");
    logThread(bridge.slug, { thread_id: threadId, event: "fire_failed", http_status: response.status });
    fail(`fire returned HTTP ${response.status}${retry ? `, retry after ${retry}s` : ""}: ${body.slice(0, 500)}`);
  }
  const result = JSON.parse(body);
  logThread(bridge.slug, {
    thread_id: threadId,
    event: "fired",
    summary: input.task.slice(0, 200),
    session_id: result.claude_code_session_id,
    session_url: result.claude_code_session_url,
    coordinator_session_id: payload.coordinator_session_id || null,
  });
  process.stdout.write(JSON.stringify({ thread_id: threadId, session_id: result.claude_code_session_id, session_url: result.claude_code_session_url }, null, 2) + "\n");
}

function textBlocks(file) {
  const source = readFileSync(join(REFERENCES, file), "utf8");
  return [...source.matchAll(/```text\n([\s\S]*?)\n```/g)].map((m) => m[1]);
}

function handoff(flags) {
  const bridge = readBridge(need(flags, "slug"));
  requireOwner(bridge, need(flags, "as"));
  if (!bridge.webhook_url) fail("no webhook_url recorded. Run update --webhook-url <url> first.");
  const [template] = textBlocks("claude-side-setup.md");
  const [projectInstructions] = textBlocks("claude-project-instructions.md");
  const [relayPrompt, directPrompt] = textBlocks("claude-routine-relay-prompt.md");
  const values = {
    "<SLUG>": bridge.slug,
    "<BOT_NAME>": bridge.owner.name,
    "<USER_NAME>": bridge.approver,
    "<PROJECT_NAME>": bridge.claude_project,
    "<REPO>": bridge.repo,
    "<MODE>": bridge.mode,
    "<ENVIRONMENT>": bridge.environment,
    "<RELAY_ROUTINE>": bridge.relay_routine,
    "<WEBHOOK_URL>": bridge.webhook_url,
  };
  const fill = (text) => Object.entries(values).reduce((t, [k, v]) => t.split(k).join(v), text);
  const prompt = template
    .replace("{{PROJECT_INSTRUCTIONS}}", () => bridge.mode === "direct" ? "(Not needed in direct mode.)" : fill(projectInstructions))
    .replace("{{ROUTINE_PROMPT}}", () => fill(bridge.mode === "direct" ? directPrompt : relayPrompt));
  const out = fill(prompt);
  const left = [...new Set(out.match(/<[A-Z][A-Z_]{2,}>/g) || [])].filter((p) => p !== "<DEFAULT_COORDINATOR_SESSION_ID>");
  if (left.length) fail(`unfilled placeholders: ${left.join(", ")}`);
  process.stdout.write(out + "\n");
}

const STATUSES = ["received", "question", "progress", "done", "error", "coordinator_online"];

function pick(body, keys) {
  for (const key of keys) {
    const value = body[key];
    if (typeof value === "string" && value.trim() !== "") return value;
  }
  return null;
}

function reply(flags) {
  const bridge = readBridge(need(flags, "slug"));
  requireOwner(bridge, need(flags, "as"));
  let raw;
  try { raw = readFileSync(0, "utf8"); } catch { fail("expected the webhook body on stdin"); }
  let body;
  try { body = JSON.parse(raw); } catch { body = null; }
  if (!body || typeof body !== "object" || Array.isArray(body)) {
    logThread(bridge.slug, { thread_id: "none", event: "reply_unparsed", raw: raw.slice(0, 2000) });
    process.stdout.write(JSON.stringify({ parsed: false, raw: raw.slice(0, 2000) }, null, 2) + "\n");
    return;
  }
  const status = typeof body.status === "string" ? body.status.trim().toLowerCase() : null;
  const normalized = {
    thread_id: pick(body, ["thread_id", "threadId", "thread"]) || "none",
    status: STATUSES.includes(status) ? status : null,
    raw_status: status,
    message: pick(body, ["message", "summary", "text", "body"]),
    pr_url: pick(body, ["pr_url", "prUrl", "pr", "pull_request_url", "url"]),
    session_url: pick(body, ["session_url", "sessionUrl"]),
    coordinator_session_id: pick(body, ["coordinator_session_id", "coordinatorSessionId", "session_id"]),
  };
  const log = join(bridgeDir(bridge.slug), "threads.jsonl");
  const lines = existsSync(log) ? readFileSync(log, "utf8").split("\n").filter(Boolean).map((l) => JSON.parse(l)) : [];
  normalized.known_thread = lines.some((e) => e.thread_id === normalized.thread_id && e.event === "fired");
  normalized.duplicate = lines.some((e) => e.event === "reply" && e.thread_id === normalized.thread_id && e.status === normalized.status && e.message === normalized.message);
  if (normalized.status === "coordinator_online" && normalized.coordinator_session_id) {
    bridge.coordinator_session_id = normalized.coordinator_session_id;
    bridge.coordinator_updated_at = new Date().toISOString();
    writeBridge(bridge);
    normalized.registry_updated = true;
  }
  logThread(bridge.slug, { event: "reply", ...normalized });
  process.stdout.write(JSON.stringify({ parsed: true, ...normalized }, null, 2) + "\n");
}

function find(flags) {
  const threadId = need(flags, "thread-id");
  const slugs = typeof flags.slug === "string" ? [flags.slug] : (existsSync(ROOT) ? readdirSync(ROOT) : []);
  for (const slug of slugs) {
    const file = join(ROOT, slug, "threads.jsonl");
    if (!existsSync(file)) continue;
    const hits = readFileSync(file, "utf8").split("\n").filter(Boolean).map((l) => JSON.parse(l)).filter((e) => e.thread_id === threadId);
    if (hits.length) { process.stdout.write(JSON.stringify({ slug, entries: hits }, null, 2) + "\n"); return; }
  }
  fail(`thread ${threadId} not found`);
}

const USAGE = `usage:
  bridge.mjs claim  --slug PROJECT_SLUG --project "Project name" --owner-name N --owner-id ID --approver NAME --repo OWNER/REPO --webhook-routine FOLDER [--environment NAME (default <slug>-env)] [--relay-routine NAME (default <slug>-relay)] [--webhook-url URL] [--mode coordinator|direct] [--coordinator SESSION_ID]
  bridge.mjs show   [--slug S]
  bridge.mjs update --slug S --as ID [--coordinator SESSION_ID] [--repo R] [--project P] [--approver A] [--environment E] [--relay-routine R] [--webhook-routine F] [--webhook-url U] [--mode M] [--new-owner-name N --new-owner-id ID]
  bridge.mjs fire   --slug S --as ID [--dry-run] < {"task": "...", "context": "...", "name": "short-name", "thread_id": "optional, reuse for follow-ups"}
  bridge.mjs handoff --slug S --as ID   (prints the complete paste prompt for the Claude Project)
  bridge.mjs reply  --slug S --as ID < <raw webhook body>   (normalizes, logs, and records coordinator_online)
  bridge.mjs find   --thread-id T [--slug S]`;

const { command, flags } = parseArgs(process.argv.slice(2));
const commands = { claim, show, update, fire, handoff, reply, find };
if (!commands[command]) { process.stderr.write(USAGE + "\n"); process.exit(command ? 1 : 0); }
await commands[command](flags);
