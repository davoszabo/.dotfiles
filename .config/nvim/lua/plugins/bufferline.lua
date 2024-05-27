return {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("bufferline").setup({})
      
      vim.keymap.set("n", "<A-l>", ":BufferLineCycleNext<CR>", {})
      vim.keymap.set("n", "<A-h>", ":BufferLineCyclePrev<CR>", {})
      vim.keymap.set("n", "<A-S-l>", ":BufferLineMoveNext<CR>", {})
      vim.keymap.set("n", "<A-S-h>", ":BufferLineMovePrev<CR>", {})
      vim.keymap.set("n", "<leader>bx", ":BufferLineCloseOthers<CR>", {})
    end,
  }
  
