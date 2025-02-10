return {
  {
    "echasnovski/mini.ai",
    version = false, -- Use the latest version
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- Code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- Function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- Class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- Tags
          d = { "%f[%d]%d+" }, -- Digits
          e = { -- Word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          -- Replace LazyVim.mini.ai_buffer with a valid option
          g = ai.gen_spec.treesitter({ a = "@text.outer", i = "@text.inner" }), -- Example for buffer-wide text selection
          u = ai.gen_spec.function_call(), -- Function call (u for "Usage")
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- Without dot in function name
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
    end,
  },
  {
    "echasnovski/mini.icons",
    version = false,
    config = function()
      require("mini.icons").setup()
    end,
  },
  {
    "echasnovski/mini.pairs",
    version = false,
    config = function()
      require("mini.pairs").setup({
        modes = { insert = true, command = true, terminal = false },
        -- Skip autopair when the next character is one of these
        skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
        -- Skip autopair when the cursor is inside these Treesitter nodes
        skip_ts = { "string" },
        -- Skip autopair when the next character is a closing pair
        -- and there are more closing pairs than opening pairs
        skip_unbalanced = true,
        -- Better handling of markdown code blocks
        markdown = true,
      })
    end,
  },
  {
    "echasnovski/mini.indentscope",
    version = false,
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      symbol = "▏",
      options = { try_as_border = true },
    },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = {
          "Trouble",
          "alpha",
          "dashboard",
          "fzf",
          "help",
          "lazy",
          "mason",
          "neo-tree",
          "notify",
          "snacks_dashboard",
          "snacks_notif",
          "snacks_terminal",
          "snacks_win",
          "toggleterm",
          "trouble",
        },
        callback = function()
          vim.b.miniindentscope_disable = true
        end,
      })

      vim.api.nvim_create_autocmd("User", {
        pattern = "SnacksDashboardOpened",
        callback = function(data)
          vim.b[data.buf].miniindentscope_disable = true
        end,
      })
    end,
  },
}
