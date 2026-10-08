#!/usr/bin/env node
// Claude bridge registry and fire helper. Node 18+, no dependencies.
// The unit is a Project package: one Claude Project, its cloud environment, and
// the bridge into it (relay routine, Grok Bot webhook routine). In relay mode the
// routine forwards each task to the Project's main thread as an Onyo Task, and
// Claude finds that thread by itself, so no session id is recorded anywhere.
// handoff prints the Claude-side paste; grokbot-setup prints the Grok Bot's reply
// routine prompt and memory note.
// Registry root: $CLAUDE_BRIDGE_HOME, default /workspace/claude-bridge.
// Each package lives in <root>/<project-slug>/project.json and threads.jsonl.

import { mkdirSync, readFileSync, writeFileSync, renameSync, appendFileSync, readdirSync, existsSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = process.env.CLAUDE_BRIDGE_HOME || "/workspace/claude-bridge";
const HELPER = resolve(fileURLToPath(import.meta.url));
const REFERENCES = join(dirname(HELPER), "..", "references");
const SLUG_RE = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;

function fail(message) {
  process.stderr.write(`bridge: ${message}\n`);
  process.exit(1);
}

// The flags each command accepts. Every flag takes a value except --dry-run.
const FLAGS = {
  claim: ["slug", "project", "owner-name", "owner-id", "approver", "repo", "webhook-routine", "environment", "relay-routine", "webhook-url", "mode"],
  show: ["slug"],
  update: ["slug", "as", "repo", "project", "approver", "environment", "relay-routine", "webhook-routine", "webhook-url", "mode", "new-owner-name", "new-owner-id"],
  fire: ["slug", "as", "dry-run"],
  handoff: ["slug", "as"],
  "grokbot-setup": ["slug", "as"],
  reply: ["slug", "as"],
  find: ["thread-id", "slug"],
};
const BOOLEAN_FLAGS = ["dry-run"];
const MODES = ["relay", "direct"];

function parseArgs(argv) {
  const [command, ...rest] = argv;
  const flags = {};
  if (!FLAGS[command]) return { command, flags };
  const allowed = FLAGS[command];
  for (let i = 0; i < rest.length; i++) {
    const arg = rest[i];
    if (!arg.startsWith("--")) fail(`unexpected argument: ${arg}`);
    const key = arg.slice(2);
    if (!allowed.includes(key)) fail(`${command} doesn't take --${key}`);
    if (BOOLEAN_FLAGS.includes(key)) { flags[key] = true; continue; }
    const next = rest[i + 1];
    if (next === undefined || next.startsWith("--")) fail(`--${key} needs a value`);
    flags[key] = next;
    i++;
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

function readLog(slug) {
  const file = join(bridgeDir(slug), "threads.jsonl");
  if (!existsSync(file)) return [];
  const entries = [];
  for (const line of readFileSync(file, "utf8").split("\n")) {
    if (!line.trim()) continue;
    try { entries.push(JSON.parse(line)); } catch { /* skip a damaged line */ }
  }
  return entries;
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
  // Check every required flag before the mkdir, so a typo can't leave an empty claimed folder.
  for (const key of ["project", "owner-name", "owner-id", "approver", "repo"]) need(flags, key);
  if (flags.mode !== undefined && !MODES.includes(flags.mode)) fail("--mode must be relay or direct");
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
  const mode = flags.mode || "relay";
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
    webhook_routine: str(flags["webhook-routine"]),
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
  if (flags.mode !== undefined && !MODES.includes(flags.mode)) fail("--mode must be relay or direct");
  if ((flags["new-owner-id"] === undefined) !== (flags["new-owner-name"] === undefined)) fail("--new-owner-id and --new-owner-name go together");
  if (typeof flags["new-owner-id"] === "string") {
    bridge.owner = { name: flags["new-owner-name"], agent_id: flags["new-owner-id"] };
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
  if (!input || typeof input !== "object" || Array.isArray(input)) fail("stdin needs a JSON object");
  if (typeof input.task !== "string" || input.task === "") fail('stdin needs a non-empty "task"');
  if (input.thread_id !== undefined && (typeof input.thread_id !== "string" || input.thread_id === "")) fail('"thread_id" must be a non-empty string');
  const name = String(input.name || "task").toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "").slice(0, 32) || "task";
  const threadId = input.thread_id || `${bridge.slug}:${name}-${timestamp()}`;
  const payload = {
    from: bridge.owner.name,
    thread_id: threadId,
    task: input.task,
    context: input.context || "",
    reply_expected: input.reply_expected !== false,
  };
  const text = JSON.stringify(payload);
  if (text.length > 65536) fail(`payload is ${text.length} characters; the limit is 65,536`);
  if (flags["dry-run"]) { process.stdout.write(text + "\n"); return; }
  const fireUrl = process.env[bridge.env.fire_url];
  const token = process.env[bridge.env.token];
  if (!fireUrl || !token) fail(`missing secret ${!fireUrl ? bridge.env.fire_url : bridge.env.token}. Request it from the user with a secret-request.`);
  // Check the URL's shape without printing it, so a swapped or mistyped secret never reaches an error message or another host.
  if (!/^https:\/\/api\.anthropic\.com\/v1\/claude_code\/routines\/[^/\s]+\/fire$/.test(fireUrl.trim())) {
    fail(`${bridge.env.fire_url} doesn't look like https://api.anthropic.com/v1/claude_code/routines/<id>/fire. Request it again (were the URL and token swapped?).`);
  }

  let response;
  let body;
  try {
    response = await fetch(fireUrl.trim(), {
      method: "POST",
      headers: { Authorization: `Bearer ${token.trim()}`, "anthropic-version": "2023-06-01", "Content-Type": "application/json" },
      body: JSON.stringify({ text }),
      signal: AbortSignal.timeout(20000),
    });
    body = await response.text();
  } catch (error) {
    // The routine may have started anyway, and /fire has no idempotency, so don't refire blindly.
    logThread(bridge.slug, { thread_id: threadId, event: "fire_unknown", error: error.name });
    fail(`fire got no answer (${error.name}). The routine may have started anyway. Ask the user to check the routine's runs before you fire ${threadId} again.`);
  }
  if (!response.ok) {
    const retry = response.headers.get("retry-after");
    logThread(bridge.slug, { thread_id: threadId, event: "fire_failed", http_status: response.status });
    fail(`fire returned HTTP ${response.status}${retry ? `, retry after ${retry}s` : ""}: ${body.slice(0, 500)}`);
  }
  let result;
  try { result = JSON.parse(body); } catch { result = {}; }
  logThread(bridge.slug, {
    thread_id: threadId,
    event: "fired",
    task: payload.task,
    context: payload.context,
    session_id: result.claude_code_session_id,
    session_url: result.claude_code_session_url,
  });
  process.stdout.write(JSON.stringify({ thread_id: threadId, session_id: result.claude_code_session_id, session_url: result.claude_code_session_url }, null, 2) + "\n");
}

function textBlocks(file) {
  const source = readFileSync(join(REFERENCES, file), "utf8");
  return [...source.matchAll(/```text\n([\s\S]*?)\n```/g)].map((m) => m[1]);
}

// Fill every <PLACEHOLDER> from the registry, and refuse to print if one is left.
function filler(bridge) {
  const values = {
    "<SLUG>": bridge.slug,
    "<BOT_NAME>": bridge.owner.name,
    "<AGENT_ID>": bridge.owner.agent_id,
    "<USER_NAME>": bridge.approver,
    "<PROJECT_NAME>": bridge.claude_project,
    "<REPO>": bridge.repo,
    "<MODE>": bridge.mode,
    "<ENVIRONMENT>": bridge.environment,
    "<RELAY_ROUTINE>": bridge.relay_routine,
    "<WEBHOOK_URL>": bridge.webhook_url || "<WEBHOOK_URL>",
    "<HELPER>": HELPER,
  };
  return (text) => Object.entries(values).reduce((t, [k, v]) => t.split(k).join(v), text);
}

function checkFilled(out) {
  const left = [...new Set(out.match(/<[A-Z][A-Z_]{2,}>/g) || [])];
  if (left.length) fail(`unfilled placeholders: ${left.join(", ")}`);
  return out;
}

function handoff(flags) {
  const bridge = readBridge(need(flags, "slug"));
  requireOwner(bridge, need(flags, "as"));
  if (!bridge.webhook_url) fail("no webhook_url recorded. Run update --webhook-url <url> first.");
  const [template] = textBlocks("claude-side-setup.md");
  const [projectInstructions] = textBlocks("claude-project-instructions.md");
  const [relayPrompt, directPrompt] = textBlocks("claude-routine-relay-prompt.md");
  if (!template || !projectInstructions || !relayPrompt || !directPrompt) fail("a ```text block is missing from the references");
  const fill = filler(bridge);
  const prompt = template
    .replace("{{PROJECT_INSTRUCTIONS}}", () => bridge.mode === "direct" ? "(Not needed in direct mode.)" : projectInstructions)
    .replace("{{ROUTINE_PROMPT}}", () => bridge.mode === "direct" ? directPrompt : relayPrompt);
  process.stdout.write(checkFilled(fill(prompt)) + "\n");
}

function grokbotSetup(flags) {
  const bridge = readBridge(need(flags, "slug"));
  requireOwner(bridge, need(flags, "as"));
  const [replyPrompt] = textBlocks("grokbot-reply-routine-prompt.md");
  const [memoryNote] = textBlocks("grokbot-memory-note.md");
  if (!replyPrompt || !memoryNote) fail("a ```text block is missing from the references");
  const fill = filler(bridge);
  const out = [
    `=== REPLY ROUTINE PROMPT: the saved prompt of your webhook routine "Claude replies ${bridge.slug}" ===`,
    fill(replyPrompt),
    "=== END REPLY ROUTINE PROMPT ===",
    "",
    "=== MEMORY NOTE: save with your memory tool's write, scope agent ===",
    fill(memoryNote),
    "=== END MEMORY NOTE ===",
  ].join("\n");
  process.stdout.write(checkFilled(out) + "\n");
}

const STATUSES = ["received", "question", "progress", "done", "error"];

function pick(body, keys) {
  for (const key of keys) {
    const value = body[key];
    if (typeof value === "string" && value.trim() !== "") return value;
  }
  return null;
}

function looksLikePr(value) {
  return /^https:\/\/[^\s]+\/(pull|merge_requests)\/\d+/.test(value);
}

function reply(flags) {
  const bridge = readBridge(need(flags, "slug"));
  requireOwner(bridge, need(flags, "as"));
  let raw;
  try { raw = readFileSync(0, "utf8"); } catch { fail("expected the webhook body on stdin"); }
  let body;
  try { body = JSON.parse(raw); } catch { body = null; }
  // A body pasted as a quoted JSON string decodes to a string. Decode it once more.
  if (typeof body === "string") { try { body = JSON.parse(body); } catch { body = null; } }
  if (!body || typeof body !== "object" || Array.isArray(body)) {
    logThread(bridge.slug, { thread_id: "none", event: "reply_unparsed", raw: raw.slice(0, 2000) });
    process.stdout.write(JSON.stringify({ parsed: false, raw: raw.slice(0, 2000) }, null, 2) + "\n");
    return;
  }
  const status = typeof body.status === "string" ? body.status.trim().toLowerCase() : null;
  const known = STATUSES.includes(status) ? status : null;
  let message = pick(body, ["message", "summary", "text", "body"]);
  if (message === null && body.message !== undefined && body.message !== null) message = JSON.stringify(body.message);
  // A bare "url" counts as the PR link only when it looks like one, because Claude also sends session URLs.
  const bareUrl = pick(body, ["url"]);
  const prUrl = pick(body, ["pr_url", "prUrl", "pr", "pull_request_url"]) || (bareUrl && looksLikePr(bareUrl) ? bareUrl : null);
  const normalized = {
    thread_id: pick(body, ["thread_id", "threadId", "thread"]) || "none",
    status: known,
    raw_status: status,
    message,
    pr_url: prUrl,
    pr_in_repo: prUrl ? prUrl.toLowerCase().startsWith(`https://github.com/${bridge.repo}/pull/`.toLowerCase()) : null,
    session_url: pick(body, ["session_url", "sessionUrl"]) || (bareUrl && !prUrl ? bareUrl : null),
  };
  const lines = readLog(bridge.slug);
  normalized.known_thread = lines.some((e) => e.thread_id === normalized.thread_id && e.event === "fired");
  normalized.duplicate = lines.some((e) => e.event === "reply" && e.thread_id === normalized.thread_id && e.status === normalized.status
    && e.raw_status === normalized.raw_status && e.message === normalized.message && e.pr_url === normalized.pr_url);
  logThread(bridge.slug, { event: "reply", ...normalized });
  process.stdout.write(JSON.stringify({ parsed: true, ...normalized }, null, 2) + "\n");
}

function find(flags) {
  const threadId = need(flags, "thread-id");
  const slugs = typeof flags.slug === "string" ? [flags.slug] : (existsSync(ROOT) ? readdirSync(ROOT) : []);
  for (const slug of slugs) {
    if (!SLUG_RE.test(slug)) continue;
    const hits = readLog(slug).filter((e) => e.thread_id === threadId);
    if (hits.length) { process.stdout.write(JSON.stringify({ slug, entries: hits }, null, 2) + "\n"); return; }
  }
  fail(`thread ${threadId} not found`);
}

const USAGE = `usage:
  bridge.mjs claim  --slug PROJECT_SLUG --project "Project name" --owner-name N --owner-id ID --approver NAME --repo OWNER/REPO [--webhook-routine FOLDER] [--environment NAME (default <slug>-env)] [--relay-routine NAME (default <slug>-relay)] [--webhook-url URL] [--mode relay|direct (default relay)]
  bridge.mjs show   [--slug S]
  bridge.mjs update --slug S --as ID [--repo R] [--project P] [--approver A] [--environment E] [--relay-routine R] [--webhook-routine F] [--webhook-url U] [--mode M] [--new-owner-name N --new-owner-id ID]
  bridge.mjs fire   --slug S --as ID [--dry-run] < {"task": "...", "context": "...", "name": "short-name", "thread_id": "optional, reuse for follow-ups"}
  bridge.mjs handoff --slug S --as ID   (prints the complete paste prompt for the Claude Project)
  bridge.mjs grokbot-setup --slug S --as ID   (prints your reply routine prompt and memory note)
  bridge.mjs reply  --slug S --as ID < <raw webhook body>   (normalizes and logs; never changes the registry)
  bridge.mjs find   --thread-id T [--slug S]`;

const { command, flags } = parseArgs(process.argv.slice(2));
const commands = { claim, show, update, fire, handoff, "grokbot-setup": grokbotSetup, reply, find };
if (!commands[command]) { process.stderr.write(USAGE + "\n"); process.exit(command ? 1 : 0); }
await commands[command](flags);
