-- Customize Mason

---@type LazySpec
return {
  -- use mason-tool-installer for automatically installing Mason packages
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    -- overrides `require("mason-tool-installer").setup(...)`
    opts = function(_, opts)
      -- Make sure to use the names found in `:Mason`
      opts.ensure_installed = {
        -- typescript / web
        "typescript-language-server",
        "tailwindcss-language-server",
        "prettierd",

        -- python
        "basedpyright",
        "ruff",
        "debugpy",

        -- install any other package
        "tree-sitter-cli",
      }

      -- c# packages need the dotnet SDK to install/run
      if vim.fn.executable "dotnet" == 1 then
        vim.list_extend(opts.ensure_installed, { "omnisharp", "csharpier" })
      end
    end,
  },
}
