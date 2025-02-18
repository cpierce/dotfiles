local M = {}

-- Function to add all unstaged files in git
M.git_add_all = function()
  vim.fn.system('git add -A')
  vim.notify(' Staged all changes.')
end

-- Function to commit your staged files in git
M.git_commit = function()
  vim.ui.input({ prompt = 'Commit message: ' }, function(msg)
    if msg then
      vim.fn.system('git commit -m ' .. vim.fn.shellescape(msg))
      vim.notify(' Committed')
    else
      vim.notify('✘ Commit aborted.')
    end
  end)
end

-- Function to push committed files in git
M.git_push = function()
  local branch = vim.fn.system('git branch --show-current'):gsub('%s+', '')
  vim.fn.system('git push origin ' .. branch)
  vim.notify(' Pushed to branch: ' .. branch)
end

-- Function to stash current unstaged files in git
M.git_stash = function()
  vim.ui.input({ prompt = 'Stash message (optional): ' }, function(msg)
    if msg then
      vim.fn.system('git stash push -m ' .. vim.fn.shellescape(msg))
    else
      vim.fn.system('git stash')
    end
    vim.notify(' Changes stashed.')
  end)
end

return M
