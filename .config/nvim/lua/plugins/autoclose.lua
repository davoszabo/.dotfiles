return {
    "m4xshen/autoclose.nvim",
    config = function()
      require("autoclose").setup({
        enable = true,
        enabled = {
          ["["] = true,
          ["]"] = true,
          ["("] = true,
          [")"] = true,
          ["{"] = true,
          ["}"] = true,
          ["\""] = true,
          ["'"] = true,
        },
      })
    end,
}

