# Vulnerability Report: CSV Formula Injection via Google Meet Attendance Export

## Overview

**Component:** OpenClaw: Attendance Export Module
**Severity:** Moderate
**Disclosed:** 5 days ago
**Summary:** Google Meet attendance CSV exports can interpret attacker-controlled participant names as spreadsheet formulas.

---

## Description

This vulnerability sits in OpenClaw's attendance-export module; specifically, the routine that serializes Google Meet participant records into `attendance.csv`. The code never inspects the first character of a cell's contents, which is the actual trigger condition spreadsheet applications use to decide whether a cell should be treated as a formula.

The attacker-controlled input is the participant **display name** in a Google Meet call. Google Meet allows users to set any display name they want before or during a meeting, and that name is captured letter-for-letter by OpenClaw's attendance tracker and written directly into the report. If that display name is set to a formula string, it injects malicious content into the exported report.

Google Meet enforces no character restrictions on display names (up to 60 characters total), making arbitrary formula payloads trivial to set.

---

## Preconditions

For this exploit to succeed, the following must occur:

1. An attacker joins a Google Meet call.
2. The attacker sets a formula-style display name (e.g., `=1+1`).
3. The meeting operator exports the attendance list to CSV.
4. The operator opens the file in a spreadsheet application with formula evaluation enabled.

OpenClaw itself never evaluates the formula, the impact occurs entirely downstream, through transmission of data, and is contingent on the victim's spreadsheet software and security settings.

---

## Root Cause

The model doesn't properly account for the **leading character** of a display name. Spreadsheet engines use this leading character as a formula trigger, **regardless of surrounding quotation marks**.

OpenClaw should do a better job of transcribing Google Meet display names during export. The agent could benefit from added context to detect potential formulas, or flag anything that doesn't resemble a normal display name.

This makes the flaw a useful example of a broader class of **"confused deliverable"** issues in agent frameworks, where untrusted external input never touches the agent's own reasoning, but rides passively through a generated artifact into a separate application that *does* evaluate it.

---

## Impact

If a victim opens the exported report under vulnerable settings, the injected formula could execute with the victim's spreadsheet privileges. Potential consequences include:

- **Data exfiltration** via functions such as `HYPERLINK` or `WEBSERVICE`
- Potentially more severe execution paths, depending on the spreadsheet application and configuration

This is fundamentally a **CSV formula injection** vulnerability, conceptually similar to prompt injection, but occurring through a different data stream entirely.

---

## Relation to Prompt Injection

> **Prompt injection is irrelevant here.**

This vulnerability requires no LLM or agent reasoning to trigger. While it is conceptually similar to prompt injection (untrusted input smuggled into a system that interprets it as instructions/code), the mechanism and attack surface are entirely different, this is a classic CSV/spreadsheet formula injection.

---

## Remediation

- OpenClaw should **neutralize formula-leading characters** before writing cell values, rather than merely quoting them.
- Any cell value beginning with a formula-indicating character (e.g., `=`, `+`, `-`, `@`, etc.) should be rendered as **literal text**, not left in a state where it can be evaluated.

### Suggested Regression Test

1. Create a mock attendance record with a display name set to a formula (e.g., `=1+1`), including variants with different leading operator characters.
2. Run the record through the export function.
3. Assert that the resulting CSV cell begins with a neutralizing prefix rather than a bare `=`, `+`, `-`, etc.
4. Verify that normal display names, including those with commas and embedded quotes, still render correctly and are not corrupted by the fix.

