return {
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'jay-babu/mason-nvim-dap.nvim', dependencies = { 'williamboman/mason.nvim' } },
    },
    config = function()
      require('config.dap-conf')()
    end,
    keys = {
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'Toggle Breakpoint' },
      {
        '<leader>dB',
        function()
          require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
        end,
        desc = 'Conditional Breakpoint',
      },
      { '<leader>dc', function() require('dap').continue() end, desc = 'Continue' },
      { '<leader>di', function() require('dap').step_into() end, desc = 'Step Into' },
      { '<leader>do', function() require('dap').step_over() end, desc = 'Step Over' },
      { '<leader>dO', function() require('dap').step_out() end, desc = 'Step Out' },
      { '<leader>dr', function() require('dap').repl.toggle() end, desc = 'Toggle REPL' },
      { '<leader>dl', function() require('dap').run_last() end, desc = 'Run Last' },
      { '<leader>dt', function() require('dap').terminate() end, desc = 'Terminate' },
    },
  },
}
