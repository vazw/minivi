-- NOTE: High priority Plugins that need to load first will be here
-- such LSP , treesister and blink cmp
local now, later = MiniDeps.now, MiniDeps.later
------------------------PLUGIN: treesister--------------------------------
local ok, ts_config = pcall(require, "nvim-treesitter.configs")
if ok then
  ---@diagnostic disable-next-line: missing-fields
  ts_config.setup({
    highlight = {
      enable = false,
    },
    -- enable indentation
    indent = { enable = true },
    ensure_installed = {
      "bash",
      "diff",
      "jsdoc",
      "json",
      "jsonc",
      "luadoc",
      "luap",
      "markdown_inline",
      "printf",
      "query",
      "regex",
      "vim",
      "vimdoc",
    },
    auto_install = true,
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection = "<C-space>",
        node_incremental = "<C-space>",
        scope_incremental = false,
        node_decremental = "<bs>",
      },
    },
  })
end

local function mason_setup() ------------------------PLUGIN: mason--------------------------------------
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

    local has_mason_path = vim.fn.stdpath("data") .. "/mason.install"
    local ensure_installed = {} ---@type string[]
    if not vim.uv.fs_stat(has_mason_path) then
      ensure_installed = {
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
        -- "clangd",
        "clang-format",
      }
      vim.fn.system({ "touch", has_mason_path })
    end
    mr.refresh(function()
      for _, tool in ipairs(ensure_installed) do
        local p = mr.get_package(tool)
        if not p:is_installed() then
          p:install()
        end
      end
    end)
  end
end

local path = vim.fn.environ()["PATH"]

now(function()
  ------------------------PLUGIN: BLINK --------------------------------
  require("blink.cmp").setup({
    -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
    -- 'super-tab' for mappings similar to vscode (tab to accept)
    -- 'enter' for enter to accept
    -- 'none' for no mappings
    --
    -- All presets have the following mappings:
    -- C-space: Open menu or open docs if already open
    -- C-n/C-p or Up/Down: Select next/previous item
    -- C-e: Hide menu
    -- C-k: Toggle signature help (if signature.enabled = true)
    --
    -- See :h blink-cmp-config-keymap for defining your own keymap
    keymap = {
      -- set to 'none' to disable the 'default' preset
      preset = "enter",
      ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-e>"] = { "hide", "fallback" },
      ["<CR>"] = { "accept", "fallback" },

      ["<Tab>"] = {
        "select_next",
        "snippet_forward",
        "fallback",
      },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
      ["<C-Tab>"] = { "snippet_forward", "fallback" },
    },
    cmdline = {
      enabled = true,
      sources = { "buffer", "cmdline" },
      keymap = {
        preset = "inherit",
        ["<CR>"] = { "select_and_accept", "fallback" },
        ["<Tab>"] = {
          "show_and_insert",
          "select_next",
        },
        ["<S-Tab>"] = { "show_and_insert", "select_prev" },

        ["<C-space>"] = { "show", "fallback" },

        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<Right>"] = { "select_next", "fallback" },
        ["<Left>"] = { "select_prev", "fallback" },

        ["<C-y>"] = { "select_and_accept" },
        ["<C-e>"] = { "cancel" },
      },
    },

    appearance = {
      use_nvim_cmp_as_default = false,
      nerd_font_variant = "mono",
    },
    completion = {
      menu = {
        auto_show = true,
        winblend = vim.o.winblend,
      },
      documentation = {
        auto_show = true,
      },
      list = {
        cycle = {
          from_top = true,
          from_bottom = true,
        },
        selection = {
          auto_insert = false,
          -- or a function
          preselect = function(_ctx)
            return not require("blink.cmp").snippet_active({ direction = 1 })
          end,
        },
      },
      trigger = {
        show_on_keyword = true,
        show_in_snippet = true,
      },
      ghost_text = { enabled = true, show_with_menu = true },
    },
    signature = { enabled = true, window = { winblend = vim.o.winblend } },

    sources = {
      -- default = { "snippets", "buffer", "omni", "path" },
      default = { "lsp", "path", "snippets", "buffer", "omni" },
      providers = {
        lsp = {
          name = "LSP",
          module = "blink.cmp.sources.lsp",

          enabled = true, -- Whether or not to enable the provider
          async = true, -- Whether we should show the completions before this provider returns, without waiting for it
          timeout_ms = 2000, -- How long to wait for the provider to return before showing completions and treating it as asynchronous
          transform_items = nil, -- Function to transform the items before they're returned
          should_show_items = true, -- Whether or not to show the items
          max_items = nil, -- Maximum number of items to display in the menu
          min_keyword_length = 0, -- Minimum number of characters in the keyword to trigger the provider
          -- If this provider returns 0 items, it will fallback to these providers.
          -- If multiple providers fallback to the same provider, all of the providers must return 0 items for it to fallback
          fallbacks = { "buffer" },
          score_offset = 99, -- Boost/penalize the score of the items
          override = nil, -- Override the source's functions
        },
      },
    },
    fuzzy = {
      implementation = "rust",
      prebuilt_binaries = { force_version = "v1.9.1" },
      sorts = {
        "exact",
        "score",
        "sort_text",
      },
    },
  })

  ------------------------PLUGIN: LSP --------------------------------

  local lsp_opts = require("plugins.lsp.config")
  --
  vim.diagnostic.config(vim.deepcopy(lsp_opts.diagnostics))
  --
  local servers = lsp_opts.servers
  local has_blink, blink = pcall(require, "blink.cmp")

  local capabilities = vim.tbl_deep_extend(
    "force",
    {},
    vim.lsp.protocol.make_client_capabilities(),
    has_blink and blink.get_lsp_capabilities()
      --  has_blink and blink.get_lsp_capabilities({
      --   textDocument = { completion = { completionItem = { snippetSupport = false } } },
      -- })
      or {},
    lsp_opts.capabilities or {}
  )

  local function setup(server)
    local server_opts = vim.tbl_deep_extend("force", {
      capabilities = vim.deepcopy(capabilities),
    }, servers[server] or {})
    if server_opts.enabled == false then
      return
    end

    vim.lsp.config(server, server_opts)
    if server_opts.autostart ~= false then
      vim.lsp.enable(server)
    end
  end

  if string.match(path, "mason") then
    later(mason_setup)
  else
    mason_setup()
  end

  for server, server_opts in pairs(servers) do
    if server_opts then
      server_opts = server_opts == true and {} or server_opts
      if server_opts.enabled ~= false then
        setup(server)
      end
    end
  end

  -- To prevents screen flashing at the start I'll load colorscheme here
  MiniDeps.add("wtfox/jellybeans.nvim")
  ------------------------PLUGIN: colorscheme--------------------------------
  local ok_jellybeans, jellybeans = pcall(require, "jellybeans")
  if ok_jellybeans then
    jellybeans.setup({
      on_highlights = function(hl, _)
        hl.ColorColumn = { bg = "#252525" }
        hl.StatusLine = { bg = "#252525" }
      end,
      on_colors = function(c)
        local dark_bg = "#121214"
        local light_bg = "#F3F3F4"
        c.background = vim.o.background == "light" and light_bg or dark_bg
      end,
    })
    vim.cmd("colorscheme jellybeans")
  end
end)
