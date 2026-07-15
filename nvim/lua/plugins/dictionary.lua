-- English word suggestions while typing in prose files (text, markdown, git
-- commits), like a regular text editor. Uses the macOS system word list.
return {
  {
    "saghen/blink.cmp",
    dependencies = { "Kaiser-Yang/blink-cmp-dictionary" },
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.default = opts.sources.default or { "lsp", "path", "snippets", "buffer" }
      table.insert(opts.sources.default, "dictionary")
      opts.sources.providers = vim.tbl_deep_extend("force", opts.sources.providers or {}, {
        dictionary = {
          module = "blink-cmp-dictionary",
          name = "Dict",
          min_keyword_length = 3,
          max_items = 8,
          score_offset = -3, -- rank below LSP/buffer suggestions
          enabled = function()
            return vim.tbl_contains({ "markdown", "text", "gitcommit", "" }, vim.bo.filetype)
          end,
          opts = {
            dictionary_files = { "/usr/share/dict/words" },
          },
        },
      })
    end,
  },
}
