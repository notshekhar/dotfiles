-- Cursor editor's dark theme (https://github.com/ydkulks/cursor-dark.nvim)
return {
  {
    "ydkulks/cursor-dark.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("cursor-dark").setup({
        style = "dark", -- the regular Cursor Dark (use "dark-midnight" for the bluer one)
        transparent = false,
      })
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "cursor-dark",
    },
  },
}
