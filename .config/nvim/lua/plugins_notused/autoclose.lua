return {
    "m4xshen/autoclose.nvim",
    config = function()
      require("autoclose").setup({
        enable = false,
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
          ["\""] = false,
          ["'"] = false,"''"
        },
      })
    end,
}

