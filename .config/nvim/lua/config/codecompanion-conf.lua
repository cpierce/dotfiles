return {
  adapters = {
    acp = {
      claude_code = function()
        return require('codecompanion.adapters').extend('claude_code', {
          -- The claude-agent-acp bridge does not read the macOS keychain, so it
          -- needs an explicit OAuth token (generate with `claude setup-token`).
          -- Read it from 1Password rather than hardcoding a secret in this repo.
          -- The op:// path is quoted because it contains spaces; `cmd:` runs via `sh -c`.
          env = {
            CLAUDE_CODE_OAUTH_TOKEN = 'cmd:op read "op://development/Claude API Credentials - Vim/credential" --no-newline',
          },
        })
      end,
    },
  },
  interactions = {
    chat = {
      -- ACP agent backed by Zed's @zed-industries/claude-code-acp bridge.
      -- Pick a model in-chat, or pin one: adapter = { name = 'claude_code', model = 'opus' }
      adapter = 'claude_code',
    },
  },
}
