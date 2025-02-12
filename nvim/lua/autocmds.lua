-- Auto Commands
--
local api = vim.api

-- Auto Yank to pbcopy
api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    if vim.v.event.operator == "y" then
      vim.fn.system("pbcopy", vim.fn.getreg('"'))
    end
  end,
})

-- Ensure the undo directory exists
if vim.fn.isdirectory(vim.fn.expand("~/.vim/undodir")) == 0 then
  vim.fn.mkdir(vim.opt.undodir:get(), "p")
end

-- Auto compile scss on save
api.nvim_create_autocmd("FileType", {
  pattern = "scss",
  callback = function()
    api.nvim_set_keymap(
      "n",
      ",m",
      ":w <BAR> !sass %:%:r.css<CR><space>",
      { noremap = true, silent = true }
    )
  end,
})

-- Auto reload file saved from the outside
api.nvim_create_autocmd(
  { "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" },
  {
    pattern = "*",
    command = "if mode() != 'c' | checktime | endif",
  }
)

-- Disable Mini IndentScope for specific filetypes
api.nvim_create_autocmd("FileType", {
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
    "toggleterm",
    "trouble",
  },
  callback = function()
    vim.b.miniindentscope_disable = true
  end,
})

-- Auto-open NeoTree on startup
api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Open filesystem view on the left
    require("neo-tree.command").execute({
      action = "show",
      source = "filesystem",
      position = "left",
      dir = vim.fn.getcwd(),
    })

    -- Cleanup invalid buffers
    for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
      if
        vim.api.nvim_buf_get_option(bufnr, "buflisted")
        and not vim.api.nvim_buf_is_loaded(bufnr)
      then
        vim.api.nvim_buf_delete(bufnr, { force = true })
      end
      if vim.api.nvim_buf_is_loaded(bufnr) then
        vim.api.nvim_buf_call(bufnr, function()
          vim.cmd("doautocmd BufRead")
        end)
      end
    end
  end,
})

-- Auto-close NeoTree before quitting
api.nvim_create_autocmd("QuitPre", {
  callback = function()
    vim.cmd("Neotree close")
    require("persistence").save()
  end,
})
