-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
-- -- Map Caps Lock (acting as F13) to exit Insert Mode to Normal Mode
vim.keymap.set("i", "<F13>", "<Esc>", { desc = "Exit Insert Mode" })

-- Map Caps Lock (acting as F13) to exit Visual Mode to Normal Mode
vim.keymap.set("v", "<F13>", "<Esc>", { desc = "Exit Visual Mode" })

-- Map Caps Lock (acting as F13) to go from Normal Mode back to Insert Mode
vim.keymap.set("n", "<F13>", "i", { desc = "Enter Insert Mode" })
