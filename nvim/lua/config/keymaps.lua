-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- gR is vim's built-in "Virtual Replace mode": easy to hit when aiming for gr
-- (references) and it silently overwrites whatever you type next. Repurpose it
-- to the same references picker so a slipped Shift is harmless.
vim.keymap.set("n", "gR", function()
  Snacks.picker.lsp_references()
end, { desc = "References", nowait = true })
