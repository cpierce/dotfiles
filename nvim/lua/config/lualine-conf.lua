local icons = require('utils.icons')
return {
  options = {
    theme = 'auto',
    section_separators = { left = icons.ui.BoldDividerRight, right = icons.ui.BoldDividerLeft },
    component_separators = { left = icons.ui.DividerRight, right = icons.ui.DividerLeft },
    icons_enabled = true,
  },
  sections = {
    lualine_a = { 'mode' },
    lualine_b = { { 'filename', path = 1 } },
    lualine_c = { 'location' },
    lualine_x = { 'progress' },
    lualine_y = { 'encoding', 'fileformat', 'filetype' },
    lualine_z = { 'branch', 'diff', 'diagnostics' },
  },
}
