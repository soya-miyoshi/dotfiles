-- User-defined plugins, loaded after LazyVim core and language extras.
-- Each table entry is a lazy.nvim plugin spec.
return {
  ----------------------------------------------------------------------------
  -- vim-tmux-navigator
  -- Seamless Ctrl+h/j/k/l between vim splits AND tmux panes.
  -- The matching tmux side is configured in dot_tmux.conf.
  ----------------------------------------------------------------------------
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<C-h>", "<cmd><C-U>TmuxNavigateLeft<cr>",     desc = "Window left  (or tmux pane)" },
      { "<C-j>", "<cmd><C-U>TmuxNavigateDown<cr>",     desc = "Window down  (or tmux pane)" },
      { "<C-k>", "<cmd><C-U>TmuxNavigateUp<cr>",       desc = "Window up    (or tmux pane)" },
      { "<C-l>", "<cmd><C-U>TmuxNavigateRight<cr>",    desc = "Window right (or tmux pane)" },
      { "<C-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Window previous" },
    },
  },

  ----------------------------------------------------------------------------
  -- Tweak the LazyVim file explorer (neo-tree) to feel more like VS Code's
  -- sidebar: open on the left with a fixed width, hide dotfiles by default.
  ----------------------------------------------------------------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      window = {
        position = "left",
        width = 32,
      },
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
    },
  },

  ----------------------------------------------------------------------------
  -- Optional: integration with Claude Code CLI from inside nvim.
  -- Disabled by default since you currently run Claude Code in a separate
  -- tmux pane. Uncomment the `enabled = true` line to try it.
  -- Repo: https://github.com/coder/claudecode.nvim
  ----------------------------------------------------------------------------
  -- {
  --   "coder/claudecode.nvim",
  --   enabled = false,
  --   dependencies = { "folke/snacks.nvim" },
  --   config = true,
  --   keys = {
  --     { "<leader>a",  nil,                              desc = "AI / Claude" },
  --     { "<leader>ac", "<cmd>ClaudeCode<cr>",            desc = "Toggle Claude" },
  --     { "<leader>af", "<cmd>ClaudeCodeFocus<cr>",       desc = "Focus Claude" },
  --     { "<leader>ar", "<cmd>ClaudeCode --resume<cr>",   desc = "Resume Claude" },
  --     { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>",       desc = "Add buffer" },
  --   },
  -- },
}
