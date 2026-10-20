# proof-before-run-hbc

**Tribute to Lilith Datura (@LilithDatura)**

This repo applies the proof-before-run principle she highlighted: require cryptographic evidence of identity and exact capabilities *before* an agent process or job is allowed to exist, rather than sandboxing after the fact.

It draws the parallel she drew between NØNOS-style capability microkernels (STARK attestation + signed capabilities before PID) and blockchain verifiable computation (STARKs / ZK proofs that a transition stayed inside stated rules).

Built as a concrete next step for HiveBrainComms (hub-first, signed, human-approved job bus).

## Core rule

No job is routed, approved, or handed to a Build pane / bot turn until:

1. The full job block (including the capability list) has a valid HMAC-SHA256 signature.
2. The requested capabilities are a subset of the policy for that `from` / `to` pair.
3. The intersection is non-empty and matches what the job asked for.

Fail closed. No PID, no pane, no turn.

## What changed from the base HiveBrainComms release

- Job format gains an explicit `caps` block (signed).
- Hub-style gate intersects job.caps with policy before any run.
- Signer covers the new field.
- Receipt on completion carries the granted capability set.

See `docs/JOB-FORMAT.md` and `tools/Sign-BusJob.ps1`.

## Status

Working design + reference implementation for the gate. Not a drop-in binary replacement for the full Windows shell; it is the security model layer you can wire into the existing hub.

Human final call. Local only. Your account, your key, your policy.
