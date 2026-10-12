"""PreToolUse gate on a coordinator's start_thread_session whose brief opens with `onyo-projects: unit thread`.
Denies the start unless the brief is, word for word, in a planning thread's report in the transcript and
project_post_id is set. onyo-mode.sh runs it with `python3 -I`, hook input on stdin. It prints a deny or nothing."""
import html, json, re, sys

REPORT = "cross-session-message from-session="


def norm(s):
    # Reports reach the coordinator HTML-escaped and indented by four spaces.
    return re.sub(r"\s+", " ", html.unescape(s)).strip().lower()


def text(content):
    if isinstance(content, str):
        return content
    return "".join(b.get("text", "") for b in content or [] if isinstance(b, dict) and b.get("type") == "text")


def reports(path):
    """Texts holding a report: prompts, queued prompts, and ReadNotifications results. Other tool output only quotes them."""
    reads, out = set(), []
    with open(path) as f:
        for line in f:
            if "ReadNotifications" not in line and REPORT not in line:
                continue
            try:
                e = json.loads(line)
            except ValueError:
                continue
            if e.get("isSidechain"):
                continue
            if e.get("type") == "attachment":
                out.append(text((e.get("attachment") or {}).get("prompt")))
                continue
            content = (e.get("message") or {}).get("content")
            if e.get("type") == "assistant":
                reads.update(b.get("id") for b in content or [] if isinstance(b, dict) and b.get("name") == "ReadNotifications")
            elif e.get("type") == "user" and isinstance(content, list) and any(isinstance(b, dict) and b.get("type") == "tool_result" for b in content):
                out += [text(b.get("content")) for b in content if isinstance(b, dict) and b.get("tool_use_id") in reads]
            elif e.get("type") == "user":
                out.append(text(content))
    return [norm(r) for r in out if REPORT in r]


inp = json.load(sys.stdin)
args = inp.get("tool_input") or {}
brief = norm(args.get("instructions") or "")
try:
    found = any(brief in r for r in reports(inp.get("transcript_path") or ""))
except OSError:
    found = True  # An unreadable transcript cannot show the brief is missing.

problems = []
if not found:
    problems.append("This brief is not in any planning thread's message. Copy the unit's brief from the planning thread's message unchanged, from its `onyo-projects: unit thread` line to the end of that brief. If no planning thread wrote a brief for this work, do not start it as a unit: forward the request to the ask's planning thread with message_thread, or start a planning thread for a new ask. If the plan came before this session started, ask the planning thread with message_thread to send the brief again.")
if not args.get("project_post_id"):
    problems.append("Set project_post_id to the message_id of your post_message that posted the plan, so the thread card stacks under it. If you have not posted the plan yet, post it first with post_message.")
if problems:
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason":
        "A unit thread starts from its plan. " + " ".join(problems) + " Then call start_thread_session again with the same title, ack and context_message_ids."}},
        separators=(",", ":"), ensure_ascii=False))
