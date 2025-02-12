return {
  options = {
    mode = "buffers",
    separator_style = "slant",
    always_show_bufferline = true,
    diagnostics = "nvim_lsp",

    diagnostics_indicator = function(_, _, diag)
      -- Define diagnostic icons manually
      local icons = {
        Error = " ", -- nf-fa-times
        Warn = " ", -- nf-fa-exclamation_triangle
      }
      local ret = (diag.error and icons.Error .. diag.error .. " " or "")
        .. (diag.warning and icons.Warn .. diag.warning or "")
      return vim.trim(ret)
    end,

    -- Offset to align with Neo-tree
    offsets = {
      { filetype = "neo-tree", text = "File Explorer", highlight = "Directory", text_align = "left" },
    },

    -- Use custom filetype icons if needed
    get_element_icon = function(opts)
      local file_icons = {
        lua = " ", -- nf-seti-lua
        markdown = " ", -- nf-fa-book
      }
      return file_icons[opts.filetype] or " " -- Default document icon
    end,

    -- Handle buffer closing
    close_command = function(n)
      vim.cmd("bdelete " .. n)
    end,
  },
}
