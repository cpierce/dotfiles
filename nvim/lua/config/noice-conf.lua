return {
  lsp = {
    override = {
      ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
      ['vim.lsp.util.stylize_markdown'] = true,
      ['cmp.entry.get_documentation'] = true,
    },
  },
  routes = {
    {
      filter = {
        event = 'msg_show',
        any = {
          { find = '%d+L, %d+B' },
          { find = '; after #%d+' },
          { find = '; before #%d+' },
          { find = require('utils.icons').git.Branch },
        },
      },
      view = 'mini',
    },
  },
  presets = {
    bottom_search = true, -- Move the search bar to the bottom
    command_palette = true, -- Command line UI like a palette
    inc_rename = true,
    long_message_to_split = true, -- Send long messages to a split
  },
}
