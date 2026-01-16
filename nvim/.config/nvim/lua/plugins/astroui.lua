-- AstroUI provides the basis for configuring the AstroNvim User Interface
-- Configuration documentation can be found with `:h astroui`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

---@type LazySpec
return {
  "AstroNvim/astroui",
  ---@type AstroUIOpts
  opts = {
    -- change colorscheme
    colorscheme = "gruvbox",
    -- AstroUI allows you to easily modify highlight groups easily for any and all colorschemes
    highlights = {
      init = function()
        return {
          -- Neo-tree selection visibility fix
          NeoTreeCursorLine = { bg = "#504945", fg = "#ebdbb2", bold = true },
          NeoTreeFileNameOpened = { fg = "#fe8019", bold = true },
          -- Telescope selection visibility fix
          TelescopeSelection = { bg = "#504945", fg = "#ebdbb2", bold = true },
          TelescopeSelectionCaret = { bg = "#504945", fg = "#fe8019", bold = true },
        }
      end,
      gruvbox = { -- gruvbox-specific overrides
      },
      astrodark = { -- a table of overrides/changes when applying the astrotheme theme
        -- Normal = { bg = "#000000" },
      },
    },
    -- Icons can be configured throughout the interface
    icons = {
      -- configure the loading of the lsp in the status line
      LSPLoading1 = "⠋",
      LSPLoading2 = "⠙",
      LSPLoading3 = "⠹",
      LSPLoading4 = "⠸",
      LSPLoading5 = "⠼",
      LSPLoading6 = "⠴",
      LSPLoading7 = "⠦",
      LSPLoading8 = "⠧",
      LSPLoading9 = "⠇",
      LSPLoading10 = "⠏",
    },
  },
}
