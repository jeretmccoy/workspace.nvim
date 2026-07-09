-- workspace/state.lua
-- Persistence: load/save workspaces.json and track the active workspace.

local M = {}
local cfg = {}
local data = { active = nil, workspaces = {} }

function M.setup(opts)
  cfg = opts
end

function M.load()
  local f = io.open(cfg.data_file, "r")
  if not f then return end
  local content = f:read("*a")
  f:close()
  if not content or content == "" then return end
  local ok, decoded = pcall(vim.json.decode, content)
  if ok and type(decoded) == "table" then
    data.workspaces = decoded
  end
end

function M.save()
  vim.fn.mkdir(vim.fn.fnamemodify(cfg.data_file, ":h"), "p")
  local f = io.open(cfg.data_file, "w")
  if not f then return end
  f:write(vim.json.encode(data.workspaces))
  f:close()
end

function M.list()
  local names = {}
  for k in pairs(data.workspaces) do table.insert(names, k) end
  table.sort(names)
  return names
end

function M.get(name)   return data.workspaces[name] end
function M.active()    return data.active end
function M.paths()
  if not data.active then return nil end
  return data.workspaces[data.active]
end

function M.set(name, paths)
  data.workspaces[name] = paths
  M.save()
end

function M.delete(name)
  data.workspaces[name] = nil
  if data.active == name then data.active = nil end
  M.save()
end

function M.set_active(name)
  if not data.workspaces[name] then return false end
  data.active = name
  return true
end

function M.deactivate()
  data.active = nil
end

function M.status()
  if not data.active then return "" end
  local paths = data.workspaces[data.active] or {}
  return string.format(" %s(%d)", data.active, #paths)
end

return M
