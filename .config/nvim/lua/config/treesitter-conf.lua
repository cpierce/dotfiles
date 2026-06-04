-- nvim-treesitter (main branch) setup.
--
-- On the `main` branch the old `setup({ ensure_installed, highlight = ... })`
-- API is gone: parsers are installed with `install()` and highlighting is
-- started per-buffer with `vim.treesitter.start()`.
return function()
  local ts = require('nvim-treesitter')

  local ensure_installed = {
    'bash',
    'c',
    'css',
    'diff',
    'html',
    'javascript',
    'json',
    'lua',
    'git_config',
    'gitcommit',
    'git_rebase',
    'gitignore',
    'gitattributes',
    'nix',
    'markdown',
    'markdown_inline',
    'php',
    'regex',
    'rust',
    'ssh_config',
    'sql',
    'toml',
    'typescript',
    'vim',
    'yaml',
    'vimdoc',
  }

  ts.setup()
  ts.install(ensure_installed)

  -- Start treesitter highlighting for every supported filetype.
  vim.api.nvim_create_autocmd('FileType', {
    callback = function(ev)
      pcall(vim.treesitter.start, ev.buf)
    end,
  })

  -- Kick off highlighting for buffers already loaded when this runs (the
  -- FileType event for them has usually already fired).
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      pcall(vim.treesitter.start, buf)
    end
  end
end
