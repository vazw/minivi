-- NOTE: Load Basic plugin such as mason,
-- comform(formatter) and statusline will be here
------------------------ Build-in Utils ---------------------------------------------
require("utils.netrw").setup()
require("utils.tabline").setup()
require("utils.statusline").setup()
require("utils.term").setup()
require("utils.colors_override")

------------------------ MiniDeps Add ------------------------------------
local add = MiniDeps.add

------------------------PLUGIN: mason--------------------------------------
local have_mason, mason = pcall(require, "mason")
if have_mason then
  mason.setup({
    ui = {
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗",
      },
    },
  })
  local mr = require("mason-registry")
  mr:on("package:install:success", function()
    vim.defer_fn(function()
      vim.api.nvim_exec_autocmds("FileType", {
        buffer = vim.api.nvim_get_current_buf(),
        modeline = false,
      })
    end, 100)
  end)

  local mason_path = vim.fn.stdpath("data") .. "/mason.install"
  local ensure_installed = {} ---@type string[]
  if not vim.uv.fs_stat(mason_path) then
    ensure_installed = {
      "black",
      "stylua",
      "prettierd",
      "isort",
      "typescript-language-server",
      "shfmt",
      "markdown-toc",
      "marksman",
      "bacon",
      "bacon-ls",
      "black",
      "isort",
      "lua-language-server",
      "pyright",
      "ruff",
      "tailwindcss-language-server",
      "tinymist",
      "typos-lsp",
      "prettypst",
      "clangd",
      -- "clang-format",
    }
  end
  mr.refresh(function()
    for _, tool in ipairs(ensure_installed) do
      local p = mr.get_package(tool)
      if not p:is_installed() then
        p:install()
      end
    end
    vim.fn.system({ "touch", mason_path })
  end)
end

------------------------PLUGIN: mini.icons-------------------------------
--- NO NEEDED to ADD mini.icons as it's already shipped with mini.nvim
local ok_MiniIcons, MiniIcons = pcall(require, "mini.icons")
if ok_MiniIcons then
  MiniIcons.setup({
    file = {
      [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
      ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
    },
    filetype = {
      dotenv = { glyph = "", hl = "MiniIconsYellow" },
    },
  })
  MiniIcons.mock_nvim_web_devicons()
  MiniIcons.tweak_lsp_kind("replace")
end

add("stevearc/conform.nvim")
------------------------PLUGIN: conform-------------------------------
local ok_conform, conform = pcall(require, "conform")
if ok_conform then
  conform.setup({
    -- Define your formatters
    formatters_by_ft = {
      lua = { "stylua" },
      -- angular, css, flow, graphql, html, json, jsx, javascript, less, markdown, scss, typescript, vue, yaml
      angular = { "prettierd", stop_after_first = true },
      javascript = { "prettierd", stop_after_first = true },
      html = { "prettierd", stop_after_first = true },
      typescript = { "prettierd", stop_after_first = true },
      css = { "prettierd", stop_after_first = true },
      scss = { "prettierd", stop_after_first = true },
      json = { "prettierd", stop_after_first = true },
      vue = { "prettierd", stop_after_first = true },
      yaml = { "prettierd", stop_after_first = true },
      graphql = { "prettierd", stop_after_first = true },
      markdown = { "markdown-toc", "prettierd" },

      c = {},
      rust = { "rustfmt", "leptosfmt" },
      -- You can use a function here to determine the formatters dynamically
      python = function(bufnr)
        if conform.get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_format", "isort", "black" }
        else
          return { "isort", "black" }
        end
      end,
      bash = { "shfmt" },
      typst = { "prettypst" },
      zig = { "zigfmt" },
      -- ["*"] = { "codespell" },
      -- ["_"] = { "trim_whitespace" },
    },
    -- Set default options
    default_format_opts = {
      lsp_format = "fallback",
      timeout_ms = 2000,
      async = true,
      quiet = true,
    },
    -- Set up format-on-save
    format_on_save = false,
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2" },
      },
      leptosfmt = {
        condition = function(_self, ctx)
          return require("lspconfig.util").root_pattern("leptosfmt.toml")(ctx.filename)
        end,
        append_args = { "--rustfmt" },
      },
    },
  })
  vim.o.formatexpr = "v:lua.require'conform'.formatexpr()"
end

add("nvimdev/indentmini.nvim")
local ok_indentmini, indentmini = pcall(require, "indentmini")
if ok_indentmini then
  indentmini.setup() -- use default config
  vim.cmd.highlight("IndentLine guifg=#303030")
  vim.cmd.highlight("IndentLineCurrent guifg=green")
end

------------------------PLUGIN: gitsigns--------------------------------------
if require("lspconfig.util").root_pattern(".git")(vim.fn.expand("%:p")) then
  add({ source = "kdheepak/lazygit.nvim", depends = { "nvim-lua/plenary.nvim" } }, {})
  add("lewis6991/gitsigns.nvim")
  local have_gitsigns, gitsigns = pcall(require, "gitsigns")
  if have_gitsigns then
    gitsigns.setup()
    vim.g.loaded_gitsigs = 1
  end
  vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })
end
