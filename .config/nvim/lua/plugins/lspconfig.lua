return {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- Example LSP server configuration (gopls)
      lspconfig.gopls.setup({
        cmd = { "busybox", "nc", "172.18.0.3", "1000" }, -- Remote gopls server in go-env container
        -- root_dir = lspconfig.util.root_pattern("main.go", "go.mod", ".git"),
        -- filetypes = { "go", "gomod" },
        root_dir = function()
            return '/workspaces/go-backend'  -- Neovim's path
        end,
        filetypes = { "go", "gomod" },
        settings = {
          gopls = {
            analyses = {
              unusedparams = true,
            },
            staticcheck = true,
          },
        },
      })
    end,
}
