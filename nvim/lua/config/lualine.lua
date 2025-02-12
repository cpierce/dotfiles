return {
  options = {
    theme = "auto",
    section_separators = { left = "", right = "" },
    component_separators = { left = "", right = "" },
    icons_enabled = true,
  },
  sections = {
    lualine_a = { "mode" },
    lualine_b = { { "filename", path = 1 } },
    lualine_c = { "location" },
    lualine_x = { "progress" },
    lualine_y = { "encoding", "fileformat", "filetype" },
    lualine_z = { "branch", "diff", "diagnostics" },
  },
}
