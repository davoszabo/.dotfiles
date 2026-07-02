return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    require("neo-tree").setup({
      filesystem = {
        use_libuv_file_watcher = true,
        filtered_items = {
          visible = true,
          show_hidden_count = true,
          hide_dotfiles = false,
          hide_gitignored = false,
          hide_by_name = {
            -- ".github",
            -- ".gitignore",
            -- "package-lock.json",
          },
          -- never_show = { ".git" },
        },
      },
    })

    vim.api.nvim_create_autocmd("FocusGained", {
      callback = function()
        require("neo-tree.events").fire_event("git_event")
        pcall(require("gitsigns").refresh)
      end,
    })

    vim.keymap.set("n", "<leader>ee", ":Neotree source=filesystem toggle=true position=left<CR>", {})
    vim.keymap.set("n", "<leader>eb", ":Neotree buffers reveal float<CR>", {})
  end,
}
