local M = {}

local function git_exec(cmd)
  local output = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify('Git error: ' .. vim.trim(output), vim.log.levels.ERROR)
    return nil
  end
  return output
end

-- Function to add all unstaged files in git
M.git_add_all = function()
  if git_exec('git add -A') then
    vim.notify(' Staged all changes.')
  end
end

-- Function to commit your staged files in git
M.git_commit = function()
  vim.ui.input({ prompt = 'Commit message: ' }, function(msg)
    if msg then
      if git_exec('git commit -m ' .. vim.fn.shellescape(msg)) then
        vim.notify(' Committed')
      end
    else
      vim.notify('✘ Commit aborted.')
    end
  end)
end

-- Function to push committed files in git
M.git_push = function()
  local result = git_exec('git branch --show-current')
  if not result then return end
  local branch = vim.trim(result)
  if git_exec('git push origin ' .. branch) then
    vim.notify(' Pushed to branch: ' .. branch)
  end
end

-- Function to stash current unstaged files in git
M.git_stash = function()
  vim.ui.input({ prompt = 'Stash message (optional): ' }, function(msg)
    local ok
    if msg then
      ok = git_exec('git stash push -m ' .. vim.fn.shellescape(msg))
    else
      ok = git_exec('git stash')
    end
    if ok then
      vim.notify(' Changes stashed.')
    end
  end)
end

return M
