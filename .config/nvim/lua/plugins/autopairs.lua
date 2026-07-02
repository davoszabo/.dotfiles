return {
    "windwp/nvim-autopairs",
    config = function()
      require("nvim-autopairs").setup({
        enable_check_bracket_line = false,
        ignored_next_char = ".+", -- ignore autopair when any character follows the cursor
      })
    end,
}
