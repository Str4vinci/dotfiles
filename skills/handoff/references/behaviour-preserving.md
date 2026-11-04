# Behaviour-preserving refactors

Use this when the next session's task must not change behaviour. Specifying the tests
is not enough. The kickoff prompt must require proof:

- Build a probe that exercises the affected surface across its option matrix, including
  the error paths, and captures the exception type and message for every invalid input.
- Hash the raw float bytes of the numerical outputs rather than comparing printed values.
- Run the probe against a `git worktree` at the current HEAD and against the working
  tree, then diff the digests. They must match exactly.
- Keep the probe in the scratchpad, not in the repo.

Write "prove equivalence, do not assume it" in the prompt and name the surface to cover.
