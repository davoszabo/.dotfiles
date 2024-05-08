return {
  "esensar/nvim-dev-container",
  dependencies = { "nvim-treesitter/nvim-treesitter" },
  config = function()
    require("devcontainer").setup({})
    vim.keymap.set("n", "<leader>ds", ":DevcontainerStart<CR>", {})
  end,
}
