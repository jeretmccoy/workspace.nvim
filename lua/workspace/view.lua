-- workspace/view.lua
-- Materialises a temporary directory of symlinks, one per workspace folder.
-- Neo-tree opens this dir so every workspace folder appears as a top-level node.

local M = {}

function M.materialize(paths, label)
  local view = vim.fn.stdpath("data") .. "/workspace-view"
  vim.fn.delete(view, "rf")
  vim.fn.mkdir(view, "p")

  local used = {}
  for _, p in ipairs(paths) do
    local base = vim.fn.fnamemodify(p, ":t")
    local name = base
    local i    = 1
    while used[name] do
      name = base .. "-" .. i
      i    = i + 1
    end
    used[name] = true
    local ok, err = pcall(vim.loop.fs_symlink, p, view .. "/" .. name, { dir = true })
    if not ok then
      vim.notify("[workspace.nvim] symlink failed for " .. p .. ": " .. tostring(err), vim.log.levels.WARN)
    end
  end

  return view
end

return M
