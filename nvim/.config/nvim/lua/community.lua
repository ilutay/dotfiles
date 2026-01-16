-- ~/.config/nvim/lua/community.lua
return {
  "AstroNvim/astrocommunity",

  -- example imports (optional)
  { import = "astrocommunity.colorscheme.gruvbox-nvim" },
  -- { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.color.transparent-nvim" },

  -- Configure transparent-nvim to exclude neo-tree and Telescope
  {
    "xiyaowong/transparent.nvim",
    opts = {
      extra_groups = {},
      exclude_groups = {
        "CursorLine", -- This is the key one - Telescope uses CursorLine for selection
        "CursorLineNr",
        "NeoTreeCursorLine",
        "NeoTreeNormal",
        "NeoTreeNormalNC",
        "TelescopeSelection",
        "TelescopeSelectionCaret",
        "TelescopePromptNormal",
        "TelescopeResultsNormal",
        "TelescopePreviewNormal",
      },
    },
  },
}

