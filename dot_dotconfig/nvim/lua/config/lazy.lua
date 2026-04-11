-- Bootstrap lazy.nvim and load LazyVim + user plugins.
-- Based on the official LazyVim starter:
-- https://github.com/LazyVim/starter

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  spec = {
    -- LazyVim core (provides sensible defaults, LSP, telescope, treesitter, etc.)
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },

    -- ===== Language extras (LSP + treesitter + formatter) =====
    -- Add or remove to taste. Each line is a fully wired-up language stack.
    { import = "lazyvim.plugins.extras.lang.typescript" },
    { import = "lazyvim.plugins.extras.lang.json" },
    { import = "lazyvim.plugins.extras.lang.yaml" },
    { import = "lazyvim.plugins.extras.lang.docker" },
    { import = "lazyvim.plugins.extras.lang.terraform" },
    { import = "lazyvim.plugins.extras.lang.go" },
    { import = "lazyvim.plugins.extras.lang.rust" },
    { import = "lazyvim.plugins.extras.lang.python" },
    { import = "lazyvim.plugins.extras.lang.markdown" },

    -- ===== Tooling extras =====
    -- Harpoon: pin frequently-edited files for instant jumping
    { import = "lazyvim.plugins.extras.editor.harpoon2" },
    -- DAP debugger UI
    { import = "lazyvim.plugins.extras.dap.core" },
    -- Test runner
    { import = "lazyvim.plugins.extras.test.core" },
    -- Better yank/paste history
    { import = "lazyvim.plugins.extras.coding.yanky" },
    -- AI completion via copilot is disabled by default; enable here if you
    -- want it. We rely on Claude Code in a separate pane instead.
    -- { import = "lazyvim.plugins.extras.coding.copilot" },

    -- ===== Your custom plugins (lua/plugins/*.lua) =====
    { import = "plugins" },
  },
  defaults = {
    -- Plugins are loaded eagerly by default; LazyVim handles lazy-loading
    -- per-plugin where it makes sense.
    lazy = false,
    version = false, -- always use the latest git commit
  },
  install = { colorscheme = { "tokyonight", "habamax" } },
  checker = { enabled = true }, -- automatically check for plugin updates
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})
