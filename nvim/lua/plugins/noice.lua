return {
  {
    'folke/noice.nvim',
    dependencies = {
      'MunifTanjim/nui.nvim',
    },
    opts = require('config.noice-conf'), -- Directly load the config
  },
}
