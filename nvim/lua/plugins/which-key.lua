-- Show the key-suggestion popup immediately (default waits 200ms), so
-- pressing d/y/g/z/Space etc. instantly lists the follow-up keys.
return {
  {
    "folke/which-key.nvim",
    opts = {
      delay = 0,
    },
  },
}
