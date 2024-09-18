return {
    "hrsh7th/nvim-cmp", -- The autocompletion plugin
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",        -- LSP source for nvim-cmp
      "hrsh7th/cmp-buffer",          -- Buffer completions
      "hrsh7th/cmp-path",            -- Path completions
      "hrsh7th/cmp-cmdline",         -- Command-line completions
      "saadparwaiz1/cmp_luasnip",    -- Snippet completions
      "L3MON4D3/LuaSnip",            -- Snippet engine
      "rafamadriz/friendly-snippets" -- A collection of snippets
    },
    config = function()
      -- Load nvim-cmp and configure it
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body) -- For luasnip users
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"] = cmp.mapping.abort(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item.
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },   -- LSP completion source
          { name = "luasnip" },    -- Snippet completion source
          { name = "buffer" },     -- Buffer completion source
          { name = "path" },       -- Path completion source
        }),
      })

      -- Use nvim-cmp in `/` and `:` (command line)
      cmp.setup.cmdline("/", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
          { name = "buffer" }
        }
      })

      cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
          { name = "path" }
        }, {
          { name = "cmdline" }
        })
      })
    end,
}

