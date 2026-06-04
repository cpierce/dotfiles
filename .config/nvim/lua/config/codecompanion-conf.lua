return {
  adapters = {
    acp = {
      claude_code = function()
        return require('codecompanion.adapters').extend('claude_code', {
          -- No token needed if you're logged into Claude Code: the adapter falls
          -- back to the agent's own ACP auth. To pin an explicit token, generate
          -- one with `claude setup-token` and read it from 1Password rather than
          -- hardcoding a secret in this (public) repo:
          -- env = {
          --   CLAUDE_CODE_OAUTH_TOKEN = 'cmd:op read op://Personal/Anthropic/credential --no-newline',
          -- },
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
