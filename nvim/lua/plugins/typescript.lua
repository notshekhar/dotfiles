-- The typescript extra maps gR to "File References" but opens results in the
-- Trouble bottom panel. Re-map it to show them in the Snacks picker popup,
-- like gr does for symbol references.
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.servers = opts.servers or {}
      opts.servers.vtsls = opts.servers.vtsls or {}
      local keys = opts.servers.vtsls.keys or {}
      opts.servers.vtsls.keys = keys
      -- appended last: for duplicate lhs, the later entry wins
      table.insert(keys, {
        "gR",
        function()
          local client = vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })[1]
          if not client then
            return
          end
          client:exec_cmd({
            title = "File References",
            command = "typescript.findAllFileReferences",
            arguments = { vim.uri_from_bufnr(0) },
          }, { bufnr = 0 }, function(_, result)
            if not result or vim.tbl_isempty(result) then
              return vim.notify("No file references", vim.log.levels.INFO)
            end
            vim.fn.setqflist({}, " ", {
              title = "File References",
              items = vim.lsp.util.locations_to_items(result, client.offset_encoding),
            })
            Snacks.picker.qflist({ title = "File References" })
          end)
        end,
        desc = "File References",
      })
    end,
  },
}
