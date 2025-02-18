return {
  options = {
    close_command = function(n)
      --styleua: ignore
      Snacks.bufdelete(n)
    end,
    right_mouse_command = function(n)
      --stylua: ignore
      Snacks.bufdelete(n)
    end,
    mode = 'buffers',
    separator_style = 'slant',
    always_show_bufferline = true,
    diagnostics = 'nvim_lsp',

    diagnostics_indicator = function(_, _, diag)
      -- Define diagnostic icons manually
      local icons = require('utils.icons')
      local ret = (diag.error and icons.diagnostics.error .. diag.error .. ' ' or '') .. (diag.warning and icons.diagnostics.warn .. diag.warning or '')
      return vim.trim(ret)
    end,

    -- Offset to align with Neo-tree
    offsets = {
      { filetype = 'snacks_layout_box' },
    },

    -- Use custom filetype icons if needed
    get_element_icon = function(opts)
      return require('mini.icons').get('filetype', opts.filetype) or require('mini.icons').get('filetype', 'unknown') -- Default document icon
    end,
  },
}
