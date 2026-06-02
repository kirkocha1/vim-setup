-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Ctrl+Tab → VSCode-style buffer switcher (Snacks)
-- Override LazyVim default <leader>bb
vim.keymap.set("n", "<leader>bb", function()
  require("snacks.picker").buffers({
    sort = { "recent" },
  })
end, { desc = "Buffer Picker" })

-- Sync every yank to tmux buffer + Mac clipboard (via OSC 52)
vim.api.nvim_create_autocmd("TextYankPost", {
  group = vim.api.nvim_create_augroup("YankSync", { clear = true }),
  callback = function()
    local event = vim.v.event
    local text = table.concat(event.regcontents, "\n")
    if not text or text == "" then
      return
    end

    -- Copy to tmux buffer (paste in other panes with Ctrl+b ])
    if vim.env.TMUX then
      vim.fn.system({ "tmux", "set-buffer", "--", text })
    end

    -- Copy via OSC 52 (Mac clipboard, works over SSH)
    -- osc52.copy expects a table of lines
    local ok, osc52 = pcall(require, "vim.ui.clipboard.osc52")
    if ok then
      osc52.copy("+")(event.regcontents)
    end
  end,
})
