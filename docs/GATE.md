# Pre-run gate

Before any job is marked routed or handed to a pane/bot:

1. Load the job file.
2. Verify HMAC over the canonical block (everything before the `sig` line). Fail closed if missing or wrong.
3. Parse `caps`.
4. Load policy (example: `policy/example-policy.json`).
5. Compute effective capabilities:
   - Start with job.caps
   - Intersect with policy[from]
   - Intersect with policy[to]
6. If the result is empty, or any requested right is missing from the intersection, refuse.
7. Only then set `routed`, log the granted set, and allow the pane or bot turn to start.

On completion the return file must include a signed receipt that lists the granted-caps actually used.

This is the practical form of “proof before it gets a PID.” The binary itself can later be attested with a stronger proof (STARK, etc.); the capability gate is the part that can be enforced today on the existing HiveBrainComms bus.
