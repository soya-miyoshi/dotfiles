-- Keymaps are loaded on the VeryLazy event.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Anything you add here overrides or extends those defaults.

local map = vim.keymap.set

-- Center cursor on half-page jumps
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })

-- Center cursor on search results
map("n", "n", "nzzzv", { desc = "Next search (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev search (centered)" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Keep yank register when pasting over a selection
map("v", "p", '"_dP', { desc = "Paste without yanking replaced text" })

-- Quick save with <leader>w (in addition to LazyVim's <C-s>)
map("n", "<leader>w", "<cmd>w<cr>", { desc = "Save file" })

-- Clear search highlight with <leader>nh
map("n", "<leader>nh", "<cmd>nohlsearch<cr>", { desc = "Clear search highlight" })
