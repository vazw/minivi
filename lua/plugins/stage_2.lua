-- NOTE: Load Basic plugin such as mason,
-- comform(formatter) and statusline will be here
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
      vim.api.nvim_exec_autocmds("FileTypes", {
        buffer = vim.api.nvim_get_current_buf(),
        modeline = false,
      })
    end, 100)
  end)

  -- local mason_path = vim.fn.stdpath("data") .. "/mason.install"
  local ensure_installed = {} ---@type string[]
  -- if not vim.uv.fs_stat(mason_path) then
  ensure_installed = {
    -- ensure_installed = {
    "black",
    "clang-format",
    "stylua",
    "prettierd",
    "isort",
    "shfmt",
    "markdown-toc",
    "bacon",
    "bacon-ls",
    "black",
    "clang-format",
    "clangd",
    "isort",
    "lua-language-server",
    "marksman",
    "pyright",
    "ruff",
    "tailwindcss-language-server",
    "tinymist",
    "typos-lsp",
    "vtsls",
    "yaml-language-server",
    "prettypst",
  }
  -- end
  mr.refresh(function()
    for _, tool in ipairs(ensure_installed) do
      local p = mr.get_package(tool)
      if not p:is_installed() then
        p:install()
      end
    end
    -- vim.fn.system({ "touch", mason_path })
  end)
end

------------------------PLUGIN: mini.icons-------------------------------
local MiniIcons = require("mini.icons")
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

add("stevearc/conform.nvim")
------------------------PLUGIN: conform-------------------------------
require("conform").setup({
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

    rust = { "rustfmt", "leptosfmt" },
    -- You can use a function here to determine the formatters dynamically
    python = function(bufnr)
      if require("conform").get_formatter_info("ruff_format", bufnr).available then
        return { "ruff_format", "isort", "black" }
      else
        return { "isort", "black" }
      end
    end,
    c = { "clang_format" },
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
  format_on_save = {
    lsp_format = "fallback",
    timeout_ms = 2000,
    async = false,
    quiet = false,
  },
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

add("nvimdev/indentmini.nvim")
require("indentmini").setup() -- use default config
vim.cmd.highlight("IndentLine guifg=#303030")
vim.cmd.highlight("IndentLineCurrent guifg=green")

add("wtfox/jellybeans.nvim")
------------------------PLUGIN: colorscheme--------------------------------
require("jellybeans").setup({
  on_highlights = function(hl, _)
    hl.ColorColumn = { bg = "#252525" }
  end,
  on_colors = function(c)
    local dark_bg = "#121214"
    local light_bg = "#F3F3F4"
    c.background = vim.o.background == "light" and light_bg or dark_bg
  end,
})
vim.cmd("colorscheme jellybeans")

------------------------PLUGIN: lualine--------------------------------
add({ source = "nvim-lualine/lualine.nvim", depends = { "echasnovski/mini.icons" } })
require("lualine").setup({
  options = {
    icons_enabled = true,
    theme = "auto",
    component_separators = { left = "", right = "" },
    section_separators = { left = "", right = "" },
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    always_show_tabline = true,
    globalstatus = vim.o.laststatus == 3,
    refresh = {
      statusline = 100,
      tabline = 100,
      winbar = 100,
    },
  },

  sections = {
    lualine_a = { "mode" },
    lualine_b = {
      "branch",
      {
        "diff",
        source = function()
          local gitsigns = vim.b.gitsigns_status_dict
          if gitsigns then
            return {
              added = gitsigns.added, ---@diagnostic disable-line:no-unknown
              modified = gitsigns.changed, ---@diagnostic disable-line:no-unknown
              removed = gitsigns.removed, ---@diagnostic disable-line:no-unknown
            }
          end
        end,
      },
      {
        "diagnostics",
        sources = { "nvim_lsp" },
        sections = { "error", "warn", "info", "hint" },
        symbols = { error = " ", warn = " ", info = " ", hint = "󰠠 " },
        colored = true,
        update_in_insert = true,
      },
    },
    lualine_c = {
      { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
      {
        "filename",
        file_status = true, -- Displays file status (readonly status, modified status)
        newfile_status = true, -- Display new file status (new file means no write after created)
        path = 4,
        symbols = {
          modified = "",
          readonly = "󰷊",
          unnamed = "󰩋[unnamed]",
          newfile = "",
        },
        padding = { left = 0, right = 1 },
      },
    },
    lualine_x = {
      { "encoding", separator = "", padding = 1, icon = { "[Encoding]", align = "left" } },
      {
        "fileformat",
        symbols = {
          unix = "unix", -- e712
          dos = "dos", -- e70f
          mac = "", -- e711
        },
        icon = { "[EOL]", align = "left" },
        padding = { left = 0, right = 1 },
      },
    },
    lualine_y = {
      {
        "lsp_status",
        icon = "",
        symbols = {
          -- Standard unicode symbols to cycle through for LSP progress:
          spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
          -- Standard unicode symbol for when LSP is done:
          done = "✓",
          -- Delimiter inserted between LSP names:
          separator = " ",
        },
        -- List of LSP names to ignore (e.g., `null-ls`):
        ignore_lsp = { "bacon_ls", "typos_lsp" },
      },
    },
    lualine_z = {
      { "progress", separator = "", padding = 0 },
      "location",
    },
  },
})

add({ source = "nvim-treesitter/nvim-treesitter-textobjects", depends = { "nvim-treesitter/nvim-treesitter" } })
------------------------PLUGIN: textobjects--------------------------------
require("nvim-treesitter-textobjects")
local move = require("nvim-treesitter.textobjects.move") ---@type table<string,fun(...)>
local configs = require("nvim-treesitter.configs")
for name, fn in pairs(move) do
  if name:find("goto") == 1 then
    move[name] = function(q, ...)
      if vim.wo.diff then
        local config = configs.get_module("textobjects.move")[name] ---@type table<string,string>
        for key, query in pairs(config or {}) do
          if q == query and key:find("[%]%[][cC]") then
            vim.cmd("normal! " .. key)
            return
          end
        end
      end
      return fn(q, ...)
    end
  end
end
