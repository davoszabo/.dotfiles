return {
    "m4xshen/autoclose.nvim",
    config = function()
      require("autoclose").setup({
        enable = true,
        options = {
            disable_when_touch = true,
        },
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

