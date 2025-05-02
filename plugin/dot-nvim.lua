-- NOTE See https://neovim.io/doc/user/lua.html

-- Normalizes a path to use "/" as the separator.
---@param path string
local function path_normalize(path)
  local normalized, _ = path:gsub("\\", "/")
  return normalized
end

-- Pops the last item from a directory path.
---@param path string The path to be popped from
local function path_pop(path)
  local popped, _ = path:gsub("/[^/]*$", "")
  return popped
end

-- Joins two paths. Assumes that the path separator is "/".
---@param left string
---@param right string
local function path_join(left, right)
  return string.format("%s/%s", left, right)
end

---@type string | nil
local base_home_dir = vim.uv.os_homedir()
if not base_home_dir then
  vim.print("$HOME or %UserProfile% is not set")
  return
end

local home_dir = path_normalize(base_home_dir)

-- Tries to find the .nvim project directory. Returns nil if it's not found.
---@param path string The path to start searching from.
local function find_dot_nvim(path)
  local dot_nvim = ".nvim"
  while not (path == "" or path == "/" or path == home_dir) do
    local maybe_dot_nvim = path_join(path, dot_nvim)
    local stats = vim.uv.fs_stat(maybe_dot_nvim)
    local type = stats and stats.type
    if type == "directory" then
      return maybe_dot_nvim
    end
    path = path_pop(path)
  end
  return nil
end
local cwd = path_normalize(vim.uv.cwd())

local dot_nvim = find_dot_nvim(cwd)

if dot_nvim then
  vim.print(".nvim found at " .. dot_nvim)
else
  vim.print(".nvim not found")
end
