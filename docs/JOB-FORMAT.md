# Job format (v3 — proof-before-run)

Plain-text block. All fields required unless marked optional. The entire block (except the final `sig` line) is covered by the HMAC.

```
id: <uuid or short id>
from: <agent or human identity>
to: <target bot / pane / lane>
lane: <optional lane name>
priority: <normal|high>
time: <ISO-8601>
job: |
  <multi-line job text>
done-when: <one-line success condition>
caps:
  panes: [build-1, hub]
  folders: [bus/, out/]
  tools: [read-file, write-file, web-search]
  network: none
  external: none
v: 3
routed: <empty until hub sets it>
sig: <HMAC-SHA256 of the canonical block>
```

## Capability rules

- `caps` is part of the signed content.
- Allowed values are drawn from a local policy file.
- Hub computes `effective = job.caps ∩ policy[from] ∩ policy[to]`.
- If effective is empty or smaller than requested, refuse before any process starts.
- `network: none` and `external: none` are the default.

## Receipt (on return)

```
receipt:
  job-id: <id>
  granted-caps: <the intersection that was allowed>
  output-hash: <blake3 or sha256 of the result>
  verified: true
sig: <HMAC over the receipt>
```

The receipt proves what was actually granted, not just what was asked.
