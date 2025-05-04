-- NOTE See https://neovim.io/doc/user/lua.html

-- Runs a function in a sandboxed environment.
---@param path string The path to the file to require in the sandboxed environment.
---@param extra_env? table Extra global variables to add to the sandbox.
local function sandbox_require(path, extra_env)
  extra_env = extra_env or {}
  -- A safe environment to run 3rd party scripts.
  local sandbox_env = {
    -- Global functions
    ipairs = ipairs,
    pairs = pairs,
    print = print,
    require = require,
    -- Global tables/libraries
    string = string,
    table = table,
  }
  for k, v in pairs(extra_env) do
    sandbox_env[k] = v
  end

  local value = loadfile(path, "t", sandbox_env)()
  return value
end

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

-- Checks if the path exists and is a file type.
---@param path string The path to check.
---@param file_type "directory" | "file" The type of file to check for.
local function is_file_type(path, file_type)
  local stats = vim.uv.fs_stat(path)
  return (stats and stats.type) == file_type
end

-- Checks if the path exists and is a directory.
---@param path string The path to check.
local function is_directory(path)
  return is_file_type(path, "directory")
end

-- Check if the path exists and is a file.
--@param path string The path to check.
local function is_file(path)
  return is_file_type(path, "file")
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
    if is_directory(maybe_dot_nvim) then
      return maybe_dot_nvim
    end
    path = path_pop(path)
  end
  return nil
end
local cwd = path_normalize(vim.uv.cwd())

local dot_nvim = find_dot_nvim(cwd)

if not dot_nvim then
  return
end

local extensions_file = path_join(dot_nvim, "extensions.lua")
local extensions = nil
if is_file(extensions_file) then
  extensions = sandbox_require(extensions_file)
  if extensions and (type(extensions) ~= "table") then
    vim.print(".nvim/extensions module did not return a table")
    extensions = nil
    return
  end
end

local settings_file = path_join(dot_nvim, "settings.lua")
if is_file(settings_file) then
  -- Takes a key-value table of `vim.opt` options and sets them.
  ---@param opts table The options to set.
  local function VimOpt(opts)
    for k, v in pairs(opts) do
      vim.opt[k] = v
    end
  end
  sandbox_require(settings_file, { VimOpt = VimOpt })
end

-- Shows a list of recommended extensions.
local function show_recommended_extensions()
  if extensions then
    for _, ext in ipairs(extensions) do
      vim.print(ext)
    end
  else
    vim.print("No recommended extensions")
  end
end

vim.api.nvim_create_user_command("ShowRecommendedExtensions", show_recommended_extensions, {
  nargs = 0,
})
