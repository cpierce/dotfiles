return function()
  -- Auto-install and wire up debug adapters via mason. The default handler
  -- configures any adapter installed through mason (rust is handled by
  -- rustaceanvim, so it's not listed here).
  require('mason-nvim-dap').setup({
    ensure_installed = { 'php' },
    automatic_installation = true,
    handlers = {
      function(config)
        require('mason-nvim-dap').default_setup(config)
      end,
    },
  })

  -- Breakpoint / stopped-line signs.
  vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DiagnosticError' })
  vim.fn.sign_define('DapBreakpointCondition', { text = '◆', texthl = 'DiagnosticWarn' })
  vim.fn.sign_define('DapBreakpointRejected', { text = '○', texthl = 'DiagnosticError' })
  vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DiagnosticInfo' })
  vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DiagnosticInfo', linehl = 'Visual' })
end
