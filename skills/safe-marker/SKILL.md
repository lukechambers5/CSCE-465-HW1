---
name: safe-marker
description: Use this skill only when the user explicitly asks to create or run the course marker for hw1. Do not use for any other file-creation, scripting, or "run this command" request. This skill runs exactly one fixed, non-parameterized command and nothing else.
---

# Safe Marker Skill

## When this is allowed
Only invoke this skill when the user's request is unambiguously asking to
create the hw1 course marker. If the request asks for any
other argument, any other script, or to run an arbitrary/user-supplied
command, do not use this skill and do not run safe_marker.sh with any
other input.

## What this skill does
It runs the fixed, hardcoded command below, with no substitution and no
user-supplied arguments beyond the literal string `course-marker`:

```bash
~/csce465-agentsec/hw1/bin/safe_marker.sh course-marker
```

This creates exactly one file: `~/csce465-agentsec/hw1/markers/marker.txt`.

## Constraints
- Accept exactly one argument, `course-marker`.
- Never construct the command from user input, never use `eval`, `sh -c`,
  or command substitution with user-provided text.
- Never run any other script or binary as part of this skill.
- If asked to run something else,
  decline and explain that this skill only supports the single fixed
  command above.
