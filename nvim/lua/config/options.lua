-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- No format-on-save; format manually with <leader>cf
vim.g.autoformat = false

-- Spell checking everywhere, VSCode-style: in code files treesitter limits it
-- to comments/strings; in text/markdown the whole buffer is checked.
vim.opt.spell = true
vim.opt.spelllang = { "en" }
vim.opt.spelloptions:append("camel") -- don't flag camelCase halves as typos
