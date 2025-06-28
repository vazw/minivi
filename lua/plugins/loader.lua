local path_package = vim.fn.stdpath("data") .. "/site/"
local mini_path = path_package .. "pack/deps/start/mini.nvim"
if not vim.uv.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  local clone_cmd = {
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/echasnovski/mini.nvim",
    mini_path,
  }
  vim.fn.system(clone_cmd)
  vim.cmd("packadd mini.nvim | helptags ALL")
  vim.cmd('echo "Installed `mini.nvim`" | redraw')
end

local MiniDeps = require("mini.deps")
-- Set up 'mini.deps' (customize to your liking)
MiniDeps.setup({ path = { package = path_package } })

local add = MiniDeps.add

add({
  source = "nvim-treesitter/nvim-treesitter",
  hooks = {
    post_checkout = function()
      vim.cmd("TSUpdate")
    end,
  },
})
add({
  source = "neovim/nvim-lspconfig",
  depends = { "mason-org/mason.nvim" },
})
add({
  source = "saghen/blink.cmp",
  depends = { "rafamadriz/friendly-snippets", "saghen/blink.compat" },
  checkout = "v1.4.1", -- check releases for latest tag
})
