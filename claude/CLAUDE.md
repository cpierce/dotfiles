# Global notes

## 1Password shell plugins are directory-scoped — run CLIs from the project folder
CLIs like `aws` are aliased through the 1Password shell plugin (`op plugin run -- <cmd>`), which binds credentials **per directory**. Always run these commands from the joined/project working directory, never from the session scratchpad (`/private/tmp/...`) or another folder.

Running from an unrecognized directory makes `op` try to interactively re-auth; because tool calls have stdin detached, the prompt never surfaces and the process **spin-waits at ~100% CPU** until killed (it does not fail fast). Reference input files by absolute `file://` path so cwd can stay the project folder. If a call hangs, clear it with `pkill -9 -f "op plugin run"`.
