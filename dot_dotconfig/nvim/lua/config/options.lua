-- Options are automatically loaded before lazy.nvim startup.
-- LazyVim defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Anything you add here overrides those defaults.

local opt = vim.opt

-- Show relative line numbers (with current line as absolute) — better for jjjj/kkkk
opt.relativenumber = true

-- Always keep some context lines around the cursor
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Use system clipboard by default (yank to *, paste from *)
opt.clipboard = "unnamedplus"

-- Tabs/indent: 2 spaces. LazyVim already does this but make it explicit.
opt.expandtab = true
opt.shiftwidth = 2
opt.tabstop = 2
opt.softtabstop = 2

-- Persistent undo across sessions
opt.undofile = true

-- Faster updates for git signs and LSP hover
opt.updatetime = 200

-- Don't show "press enter" prompt as much
opt.shortmess:append("c")
