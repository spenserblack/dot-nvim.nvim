# `.nvim`

## Description

Set up project-specific configuration for Neovim with a `.nvim/` directory.

This plugin will search upwards from the current working directory until it finds a
`.nvim/` directory. If your current working directory is under the home directory,
it will never search in the home directory or above.

## Folder structure

Project configuration is defined by Lua scripts. Before running the Lua scripts, the
global table is cleared except for a few values that are considered safe. Regardless,
you should inspect a `.nvim/` folder before you allow this plugin to execute the
modules.

### `.nvim/extensions.lua`

This module should return a table of recommended extensions. Extensions will *not* be
automatically installed. Users can view recommended extensions by calling
`:ShowRecommendedExtensions`.

To be honest, you could just *read* `.nvim/extensions.lua` instead of calling
`:ShowRecommendedExtensions`, and it would be roughly as useful. Ideas on how to make
this more useful are welcome.

#### Example

```lua
-- extensions.lua
return {
  "folke/lazy.nvim",
  "github/copilot.vim",
}
```

### `.nvim/settings.lua`

This module will define settings. The global `VimOpt` function is available to set
`vim.opt` values. The function takes one argument: a table that maps keys to values.

#### Example

```lua
-- settings.lua
VimOpt {
  colorcolumn = "88",
  spell = true,
}
```
