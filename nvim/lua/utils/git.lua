local M = {}

local function git_notify(msg)
  vim.api.nvim_exec2("echo ' Git: " .. msg .. "'", {})
end

-- Function to refresh neo-tree sources manager status window
local function refresh_git_status()
  require("neo-tree.sources.manager").refresh("git_status")
end

-- Function to add all unstaged files in git
M.git_add_all = function()
  vim.fn.system("git add -A")
  git_notify(" Staged all changes.")
  refresh_git_status()
end

-- Function to commit your staged files in git
M.git_commit = function()
  vim.ui.input({ prompt = "Commit message: " }, function(msg)
    if msg then
      vim.fn.system("git commit -m " .. vim.fn.shellescape(msg))
      git_notify(" Committed")
      refresh_git_status()
    else
      git_notify("✘ Commit aborted.")
    end
  end)
end

-- Function to push committed files in git
M.git_push = function()
  local branch = vim.fn.system("git branch --show-current"):gsub("%s+", "")
  vim.fn.system("git push origin " .. branch)
  git_notify(" Pushed to branch: " .. branch)
  refresh_git_status()
end

-- Function to stash current unstaged files in git
M.git_stash = function()
  vim.ui.input({ prompt = "Stash message (optional): " }, function(msg)
    if msg then
      vim.fn.system("git stash push -m " .. vim.fn.shellescape(msg))
    else
      vim.fn.system("git stash")
    end
    git_notify(" Changes stashed.")
    refresh_git_status()
  end)
end

return M
