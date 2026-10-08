#!/usr/bin/env node
// Claude bridge registry and fire helper. Node 18+, no dependencies.
// The unit is a Project package: one Claude Project, its cloud environment, and
// the bridge into it (relay routine, Grok Bot webhook routine). Messages are plain
// Markdown both ways. The only fixed structure is the first line of every message
// the bot sends: # ONYO MESSAGE. The Project's main thread tracks its own threads,
// so the bot tracks none.
// handoff prints the Claude-side paste; grokbot-setup prints the Grok Bot's reply
// routine prompt and memory note.
// Registry root: $CLAUDE_BRIDGE_HOME, default /workspace/claude-bridge.
// Each package lives in <root>/<project-slug>/project.json.

import { mkdirSync, readFileSync, writeFileSync, renameSync, readdirSync, existsSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const ROOT = process.env.CLAUDE_BRIDGE_HOME || "/workspace/claude-bridge";
const HELPER = resolve(fileURLToPath(import.meta.url));
const REFERENCES = join(dirname(HELPER), "..", "references");
const SLUG_RE = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const HEADER = "# ONYO MESSAGE";
const FIRE_LIMIT = 65536;

function fail(message) {
  process.stderr.write(`bridge: ${message}\n`);
  process.exit(1);
}

// The flags each command accepts. Every flag takes a value except --dry-run.
const FLAGS = {
  claim: ["slug", "project", "owner-name", "owner-id", "repo", "webhook-routine", "environment", "relay-routine", "webhook-url"],
  show: ["slug"],
  update: ["slug", "as", "repo", "project", "environment", "relay-routine", "webhook-routine", "webhook-url", "new-owner-name", "new-owner-id"],
  fire: ["slug", "as", "dry-run"],
  handoff: ["slug", "as"],
  "grokbot-setup": ["slug", "as"],
};
const BOOLEAN_FLAGS = ["dry-run"];

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

function str(value) {
  return typeof value === "string" && value !== "" ? value : null;
}

function claim(flags) {
  const slug = need(flags, "slug");
  const dir = bridgeDir(slug);
  // Check every required flag before the mkdir, so a typo can't leave an empty claimed folder.
  for (const key of ["project", "owner-name", "owner-id", "repo"]) need(flags, key);
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
  const prefix = envPrefix(slug);
  const bridge = {
    version: 3,
    slug,
    claude_project: need(flags, "project"),
    owner: { name: need(flags, "owner-name"), agent_id: need(flags, "owner-id") },
    repo: need(flags, "repo"),
    environment: str(flags.environment) || `${slug}-env`,
    relay_routine: str(flags["relay-routine"]) || `${slug}-relay`,
    webhook_routine: str(flags["webhook-routine"]),
    webhook_url: str(flags["webhook-url"]),
    env: { fire_url: `${prefix}_FIRE_URL`, token: `${prefix}_TOKEN` },
    created_at: new Date().toISOString(),
  };
  writeBridge(bridge);
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
    process.stdout.write(`${b.slug}\tproject=${b.claude_project}\towner=${b.owner.name} (${b.owner.agent_id})\tenvironment=${b.environment}\trepo=${b.repo}\n`);
  }
}

function update(flags) {
  const bridge = readBridge(need(flags, "slug"));
  requireOwner(bridge, need(flags, "as"));
  if ((flags["new-owner-id"] === undefined) !== (flags["new-owner-name"] === undefined)) fail("--new-owner-id and --new-owner-name go together");
  if (typeof flags["new-owner-id"] === "string") {
    bridge.owner = { name: flags["new-owner-name"], agent_id: flags["new-owner-id"] };
  }
  const fields = { repo: "repo", project: "claude_project", environment: "environment", "relay-routine": "relay_routine", "webhook-routine": "webhook_routine", "webhook-url": "webhook_url" };
  for (const [flag, field] of Object.entries(fields)) {
    if (typeof flags[flag] === "string") bridge[field] = flags[flag];
  }
  writeBridge(bridge);
  process.stdout.write(JSON.stringify(bridge, null, 2) + "\n");
}

async function fire(flags) {
  const bridge = readBridge(need(flags, "slug"));
  requireOwner(bridge, need(flags, "as"));
  let input;
  try { input = readFileSync(0, "utf8"); } catch { fail("expected the Markdown message on stdin"); }
  const body = input.replace(/^﻿/, "").trim();
  if (body === "") fail("the message on stdin is empty");
  const message = body.split("\n", 1)[0].trim() === HEADER ? body : `${HEADER}\n\n${body}`;
  if (message.length > FIRE_LIMIT) fail(`the message is ${message.length} characters; the limit is 65,536`);
  if (flags["dry-run"]) { process.stdout.write(message + "\n"); return; }
  const fireUrl = process.env[bridge.env.fire_url];
  const token = process.env[bridge.env.token];
  if (!fireUrl || !token) fail(`missing secret ${!fireUrl ? bridge.env.fire_url : bridge.env.token}. Request it from the user with a secret-request.`);
  // Check the URL's shape without printing it, so a swapped or mistyped secret never reaches an error message or another host.
  if (!/^https:\/\/api\.anthropic\.com\/v1\/claude_code\/routines\/[^/\s]+\/fire$/.test(fireUrl.trim())) {
    fail(`${bridge.env.fire_url} doesn't look like https://api.anthropic.com/v1/claude_code/routines/<id>/fire. Request it again (were the URL and token swapped?).`);
  }

  let response;
  let text;
  try {
    response = await fetch(fireUrl.trim(), {
      method: "POST",
      headers: { Authorization: `Bearer ${token.trim()}`, "anthropic-version": "2023-06-01", "Content-Type": "application/json" },
      body: JSON.stringify({ text: message }),
      signal: AbortSignal.timeout(20000),
    });
    text = await response.text();
  } catch (error) {
    // The routine may have started anyway, and /fire has no idempotency, so don't refire blindly.
    fail(`fire got no answer (${error.name}). The routine may have started anyway. Ask the user to check the routine's runs before you send this message again.`);
  }
  if (!response.ok) {
    const retry = response.headers.get("retry-after");
    fail(`fire returned HTTP ${response.status}${retry ? `, retry after ${retry}s` : ""}: ${text.slice(0, 500)}`);
  }
  let result;
  try { result = JSON.parse(text); } catch { result = {}; }
  process.stdout.write(JSON.stringify({ session_id: result.claude_code_session_id, session_url: result.claude_code_session_url }, null, 2) + "\n");
}

function textBlocks(file) {
  const source = readFileSync(join(REFERENCES, file), "utf8");
  return [...source.matchAll(/```text\n([\s\S]*?)\n```/g)].map((m) => m[1]);
}

// Fill every <PLACEHOLDER> from the registry, and refuse to print if one is left.
function filler(bridge) {
  const values = {
    "<SLUG>": bridge.slug,
    "<AGENT_ID>": bridge.owner.agent_id,
    "<PROJECT_NAME>": bridge.claude_project,
    "<REPO>": bridge.repo,
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
  const [relayPrompt] = textBlocks("claude-routine-relay-prompt.md");
  if (!template || !projectInstructions || !relayPrompt) fail("a ```text block is missing from the references");
  const prompt = template
    .replace("{{PROJECT_INSTRUCTIONS}}", () => projectInstructions)
    .replace("{{ROUTINE_PROMPT}}", () => relayPrompt);
  process.stdout.write(checkFilled(filler(bridge)(prompt)) + "\n");
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

const USAGE = `usage:
  bridge.mjs claim  --slug PROJECT_SLUG --project "Project name" --owner-name N --owner-id ID --repo OWNER/REPO [--webhook-routine FOLDER] [--environment NAME (default <slug>-env)] [--relay-routine NAME (default <slug>-relay)] [--webhook-url URL]
  bridge.mjs show   [--slug S]
  bridge.mjs update --slug S --as ID [--repo R] [--project P] [--environment E] [--relay-routine R] [--webhook-routine F] [--webhook-url U] [--new-owner-name N --new-owner-id ID]
  bridge.mjs fire   --slug S --as ID [--dry-run] < <Markdown message; "${HEADER}" is added as the first line if it's missing>
  bridge.mjs handoff --slug S --as ID   (prints the complete paste prompt for the Claude Project)
  bridge.mjs grokbot-setup --slug S --as ID   (prints your reply routine prompt and memory note)`;

const { command, flags } = parseArgs(process.argv.slice(2));
const commands = { claim, show, update, fire, handoff, "grokbot-setup": grokbotSetup };
if (!commands[command]) { process.stderr.write(USAGE + "\n"); process.exit(command ? 1 : 0); }
await commands[command](flags);
