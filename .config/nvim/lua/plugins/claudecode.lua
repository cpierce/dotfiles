-- Claude Code agent integration: runs the `claude` CLI in a split and speaks
-- the same IDE protocol as the official VS Code extension, so it sees the
-- current selection/buffers and presents its edits as native diffs.
-- Uses the existing `claude` login (subscription), no extra token needed.
return {
  {
    'coder/claudecode.nvim',
    dependencies = { 'folke/snacks.nvim' },
    opts = {},
    keys = {
      { '<leader>at', '<cmd>ClaudeCode<cr>', noremap = true, silent = true, desc = 'Toggle Terminal (Claude Code)' },
      { '<leader>af', '<cmd>ClaudeCodeFocus<cr>', noremap = true, silent = true, desc = 'Focus (Claude Code)' },
      { '<leader>ar', '<cmd>ClaudeCode --resume<cr>', noremap = true, silent = true, desc = 'Resume Session (Claude Code)' },
      { '<leader>ab', '<cmd>ClaudeCodeAdd %<cr>', noremap = true, silent = true, desc = 'Add Current Buffer (Claude Code)' },
      { '<leader>as', '<cmd>ClaudeCodeSend<cr>', mode = 'v', noremap = true, silent = true, desc = 'Send Selection (Claude Code)' },
      { '<leader>ay', '<cmd>ClaudeCodeDiffAccept<cr>', noremap = true, silent = true, desc = 'Accept Diff (Claude Code)' },
      { '<leader>an', '<cmd>ClaudeCodeDiffDeny<cr>', noremap = true, silent = true, desc = 'Deny Diff (Claude Code)' },
    },
  },
}
