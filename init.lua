vim.g.loaded_zipPlugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_2html_plugin = 1
vim.g.loaded_ruby_provider = 1

require("config")
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

local add, now, later = MiniDeps.add, MiniDeps.now, MiniDeps.later

-- STAGE 1: Load treesister, lspconfig and blink.cmp
-- STAGE 2: Load Basic plugin such as mason, comform(formatter) and statusline
-- STAGE 3: Load appearance such as Colorizer, Icons/Themes and Git things

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
add("wtfox/jellybeans.nvim")
add("stevearc/conform.nvim")
add("ibhagwan/fzf-lua")

-- PLUGIN: treesister
---@diagnostic disable-next-line: missing-fields
require("nvim-treesitter.configs").setup({
  -- enable syntax highlighting

  highlight = {
    enable = false,
  },
  -- enable indentation
  indent = { enable = true },

  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "diff",
    "html",
    "javascript",
    "jsdoc",
    "json",
    "jsonc",
    "lua",
    "luadoc",
    "luap",
    "markdown",
    "markdown_inline",
    "printf",
    "python",
    "query",
    "regex",
    "toml",
    "tsx",
    "typescript",
    "vim",
    "vimdoc",
    "xml",
    "yaml",
  },
  -- auto install above language parsers
  auto_install = true,
  textobjects = {
    lsp_interop = {
      enable = true,
      border = "none",
      floating_preview_opts = {},
      peek_definition_code = {
        ["<leader>df"] = { query = "@function.outer", desc = "Peek Definition Code" },
        ["<leader>dF"] = { query = "@class.outer", desc = "Peek Definition Code" },
      },
    },
    select = {
      enable = true,

      -- Automatically jump forward to textobj, similar to targets.vim
      lookahead = true,

      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ["af"] = { query = "@function.outer", desc = "Select outer function" },
        ["if"] = { query = "@function.inner", desc = "Select inner function" },
        ["ac"] = { query = "@class.outer", desc = "Select outer class" },
        ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
        ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
      },
      selection_modes = {
        ["@parameter.outer"] = "v", -- charwise
        ["@function.outer"] = "V", -- linewise
        ["@class.outer"] = "<c-v>", -- blockwise
      },
      include_surrounding_whitespace = true,
    },

    swap = {
      enable = true,
      swap_next = {
        ["<leader>a"] = { query = "@parameter.inner", desc = "Swap next" },
      },
      swap_previous = {
        ["<leader>A"] = { query = "@parameter.inner", desc = "Swap previous" },
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        ["]f"] = { query = "@function.outer", desc = "Next Function Start" },
        ["]]"] = { query = "@class.outer", desc = "Next Class Start" },
        ["]o"] = { query = "@loop.*", desc = "Select Loop" },
        ["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
        ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
      },
      goto_next_end = {
        ["]F"] = { query = "@function.outer", desc = "Goto Next Function End" },
        ["]["] = { query = "@class.outer", desc = "Goto Next Class End" },
      },
      goto_previous_start = {
        ["[f"] = { query = "@function.outer", desc = "Goto Previous Function Start" },
        ["[["] = { query = "@class.outer", desc = "Goto Previous Class Start" },
      },
      goto_previous_end = {
        ["[F"] = { query = "@function.outer", desc = "Goto Previous Function End" },
        ["[]"] = { query = "@class.outer", desc = "Goto Previous Class End" },
      },
      goto_next = {
        ["]w"] = { query = "@conditional.outer", desc = "Goto Next Node" },
      },
      goto_previous = {
        ["[w"] = { query = "@conditional.outer", desc = "Goto Previous Node" },
      },
    },
  },
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

now(function()
  -- PLUGIN: LSP
  local lsp_opts = {
    diagnostics = {
      underline = true,
      update_in_insert = true,
      virtual_text = {
        spacing = 4,
        source = "if_many",
        prefix = "●",
        -- this will set set the prefix to a function that returns the diagnostics icon based on the severity
        -- this only works on a recent 0.10.0 build. Will be set to "●" when not supported
        -- prefix = "icons",
      },
      severity_sort = true,
      signs = {
        priority = 1,
        text = {
          [vim.diagnostic.severity.ERROR] = " ",
          [vim.diagnostic.severity.WARN] = " ",
          [vim.diagnostic.severity.HINT] = "󰠠 ",
          [vim.diagnostic.severity.INFO] = " ",
        },
      },
    },

    capabilities = {
      workspace = {
        fileOperations = {
          didRename = true,
          willRename = true,
        },
      },
    },
    -- options for vim.lsp.buf.format
    -- `bufnr` and `filter` is handled by the LazyVim formatter,
    -- but can be also overridden when specified
    format = {
      formatting_options = nil,
      timeout_ms = 1000,
    },
    servers = {
      pyright = {
        settings = {
          pyright = {
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              -- Ignore all files for analysis to exclusively use Ruff for linting
              ignore = { "*" },
            },
          },
        },
      },
      cssls = {},

      ruff = {
        on_attach = function(client, _bufnr)
          if client.name == "ruff_lsp" then
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
          end
        end,
      },
      vtsls = { enabled = true },
      bacon_ls = {
        enabled = true,
        init_options = {
          updateOnSave = true,
          updateOnSaveWaitMillis = 1000,
        },
      },

      rust_analyzer = {
        enabled = true,
        -- autostart = false,
        settings = {
          -- rust-analyzer language server configuration
          ["rust-analyzer"] = {
            cargo = {
              allFeatures = true,
              loadOutDirsFromCheck = true,
              buildScripts = {
                enable = true,
              },
            },
            check = {
              command = "clippy",
              extraArgs = {
                "--no-deps",
                "--workspace",
                "--tests",
                "--all-targets",
                "--all-features",
              },
            },
            checkOnSave = false,
            diagnostics = { enable = false },
            procMacro = {
              enable = true,
              ignored = {
                ["async-trait"] = { "async_trait" },
                ["napi-derive"] = { "napi" },
                ["async-recursion"] = { "async_recursion" },
                leptos = { "server", "component" },
              },
            },
            files = {
              excludeDirs = {
                ".direnv",
                ".git",
                ".github",
                ".gitlab",
                "bin",
                "node_modules",
                "target",
                "venv",
                ".venv",
                "registry",
              },
            },
          },
        },
      },
      tailwindcss = {
        root_dir = function(...)
          return require("lspconfig.util").root_pattern("tailwind.config.js")(...)
        end,
        filetypes = { "html", "css", "rust" },
        settings = {
          tailwindCSS = {
            includeLanguages = {
              rust = "html",
            },
          },
        },
      },

      tsserver = {
        enabled = false,
        -- root_dir = function(...)
        --   return require("lspconfig.util").root_pattern(".git")(...)
        -- end,
        -- single_file_support = false,
        settings = {
          typescript = {
            inlayHints = {
              includeInlayParameterNameHints = "literal",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = false,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
          javascript = {
            inlayHints = {
              includeInlayParameterNameHints = "all",
              includeInlayParameterNameHintsWhenArgumentMatchesName = false,
              includeInlayFunctionParameterTypeHints = true,
              includeInlayVariableTypeHints = true,
              includeInlayPropertyDeclarationTypeHints = true,
              includeInlayFunctionLikeReturnTypeHints = true,
              includeInlayEnumMemberValueHints = true,
            },
          },
        },
      },

      zls = {},
      clangd = {
        keys = {
          { "<leader>ch", "<cmd>ClangdSwitchSourceHeader<cr>", desc = "Switch Source/Header (C/C++)" },
        },
        root_dir = function(fname)
          return require("lspconfig.util").root_pattern(
            "Makefile",
            "configure.ac",
            "configure.in",
            "config.h.in",
            "meson.build",
            "meson_options.txt",
            "build.ninja"
          )(fname) or require("lspconfig.util").root_pattern("compile_commands.json", "compile_flags.txt")(
            fname
          ) or vim.fs.dirname(vim.fs.find(".git", { path = fname, upward = true })[1])
        end,
        capabilities = {
          offsetEncoding = { "utf-16" },
        },
        cmd = {
          "clangd",
          "--background-index",
          "--clang-tidy",
          "--header-insertion=iwyu",
          "--completion-style=detailed",
          "--function-arg-placeholders",
          "--fallback-style=llvm",
        },
        init_options = {
          usePlaceholders = true,
          completeUnimported = true,
          clangdFileStatus = true,
        },
      },

      html = {},
      phpactor = {
        enabled = true,
      },
      marksman = {},
      yamlls = {
        settings = {
          yaml = {
            keyOrdering = false,
          },
        },
      },
      tinymist = {
        single_file_support = true,
        filetypes = "typst",
        settings = {
          exportPdf = "onSave",
        },
      },
      typos_lsp = {
        -- autostart = false,
        init_options = {
          config = "~/.config/typos.toml",
        },
      },

      lua_ls = {
        enabled = true,
        single_file_support = true,
        settings = {
          Lua = {
            workspace = {
              checkThirdParty = false,
              library = vim.api.nvim_get_runtime_file("", true),
            },
            -- completion = {
            --   callSnippet = "Disable",
            --   keywordSnippet = "Disable",
            -- },
            misc = {
              parameters = {
                -- "--log-level=trace",
              },
            },
            hint = {
              enable = true,
              setType = false,
              paramType = true,
              paramName = "Disable",
              semicolon = "Disable",
              arrayIndex = "Disable",
            },
            doc = {
              privateName = { "^_" },
            },
            type = {
              castNumberToInteger = true,
            },
            diagnostics = {
              globals = { "vim", "require" },
              disable = { "incomplete-signature-doc", "trailing-space" },
              -- enable = false,
              groupSeverity = {
                strong = "Warning",
                strict = "Warning",
              },
              groupFileStatus = {
                ["ambiguity"] = "Opened",
                ["await"] = "Opened",
                ["codestyle"] = "None",
                ["duplicate"] = "Opened",
                ["global"] = "Opened",
                ["luadoc"] = "Opened",
                ["redefined"] = "Opened",
                ["strict"] = "Opened",
                ["strong"] = "Opened",
                ["type-check"] = "Opened",
                ["unbalanced"] = "Opened",
                ["unused"] = "Opened",
              },
              unusedLocalExclude = { "_*" },
            },
            format = {
              enable = true,
              defaultConfig = {
                indent_style = "space",
                indent_size = "2",
                continuation_indent_size = "2",
              },
            },
          },
        },
      },
    },
  }

  vim.diagnostic.config(vim.deepcopy(lsp_opts.diagnostics))

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
    -- server_opts.autostart = false

    require("lspconfig")[server].setup(server_opts)
  end

  for server, server_opts in pairs(servers) do
    if server_opts then
      server_opts = server_opts == true and {} or server_opts
      if server_opts.enabled ~= false then
        setup(server)
      end
    end
  end
  -- PLUGIN: BLINK
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
      { completion = { ghost_text = { enabled = true } } },
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
      default = { "lsp", "path", "snippets", "buffer" },
      providers = {
        -- emoji = {
        --   name = "Emoji",
        --   module = "blink-emoji",
        --
        --   score_offset = 15, -- Tune by preference
        --   opts = { insert = true }, -- Insert emoji (default) or complete its name
        --   should_show_items = function()
        --     return vim.tbl_contains(
        --       -- Enable emoji completion only for git commits and markdown.
        --       -- By default, enabled for all file-types.
        --       { "gitcommit", "markdown", "html", "_", "" },
        --       vim.o.filetype
        --     )
        --   end,
        -- },

        lsp = {
          name = "LSP",
          module = "blink.cmp.sources.lsp",

          --- NOTE: All of these options may be functions to get dynamic behavior
          --- See the type definitions for more information
          enabled = true, -- Whether or not to enable the provider
          async = false, -- Whether we should show the completions before this provider returns, without waiting for it
          timeout_ms = 2000, -- How long to wait for the provider to return before showing completions and treating it as asynchronous
          transform_items = nil, -- Function to transform the items before they're returned
          should_show_items = true, -- Whether or not to show the items
          max_items = nil, -- Maximum number of items to display in the menu
          min_keyword_length = 0, -- Minimum number of characters in the keyword to trigger the provider
          -- If this provider returns 0 items, it will fallback to these providers.
          -- If multiple providers fallback to the same provider, all of the providers must return 0 items for it to fallback
          fallbacks = {},
          score_offset = 99, -- Boost/penalize the score of the items
          override = nil, -- Override the source's functions
        },
      },
    },
    fuzzy = {
      implementation = "rust",
      prebuilt_binaries = { force_version = "v1.4.1" },
    },
    sorts = {
      "score",
      "sort_text",
    },
    opts_extend = {
      "sources.completion.enabled_providers",
      "sources.compat",
      "sources.default",
    },
  })
end)

later(function()
  -- PLUGIN: mason
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

    local mason_path = vim.fn.stdpath("data") .. "mason.install"
    local ensure_installed = {} ---@type string[]
    if not vim.uv.fs_stat(mason_path) then
      ensure_installed = {
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

  -- PLUGIN: mini.icons
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

  -- PLUGIN: conform
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

  add({
    source = "rayliwell/tree-sitter-rstml",
    hooks = {
      post_checkout = function()
        vim.cmd("TSUpdate")
      end,
    },
  }, {})

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
end)

add({ source = "nvim-treesitter/nvim-treesitter-textobjects", depends = { "nvim-treesitter/nvim-treesitter" } })
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

later(function()
  add("akinsho/bufferline.nvim")
  require("bufferline").setup({
    options = {
      diagnostics = "nvim_lsp",
      always_show_bufferline = false,
      mode = "tabs",
      show_buffer_close_icons = false,
      show_close_icon = false,
      color_icons = true,
    },
  })
  add("windwp/nvim-ts-autotag")
  add("windwp/nvim-autopairs")
  require("nvim-autopairs").setup({})
  require("nvim-ts-autotag").setup({
    opts = {
      -- Defaults
      enable_close = true, -- Auto close tags
      enable_rename = true, -- Auto rename pairs of tags
      enable_close_on_slash = false, -- Auto close on trailing </
    },
  })
  -- PLUGIN: colorscheme
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

  -- PLUGIN: toggleterm
  add("akinsho/toggleterm.nvim")
  require("toggleterm").setup({
    size = function(term)
      if term.direction == "horizontal" then
        return 15
      elseif term.direction == "vertical" then
        return vim.o.columns * 0.4
      end
    end,
    open_mapping = [[<c-/>]],
    direction = "horizontal",
  })
  vim.keymap.set("n", "<c-/>", '<Cmd>exe v:count1 . "ToggleTerm"<CR>', { desc = "Toggle Term" })
  -- PLUGIN: fzf
  require("fzf-lua").setup({
    files = {
      actions = {
        ["ctrl-u"] = function(_, opts)
          local parent = vim.fn.fnamemodify(opts.cwd or vim.uv.cwd() or vim.fn.getcwd(), ":h")
          require("fzf-lua").files({ cwd = parent })
        end,
      },
    },
  })
  vim.cmd("FzfLua register_ui_select")

  vim.keymap.set("n", "sf", function()
    require("fzf-lua").files()
  end, { desc = "File File" })
  vim.keymap.set("n", "sF", function()
    -- require("fzf-lua").files({ cwd = vim.fn.getcwd() })
    require("fzf-lua").files({ cwd = vim.fn.expand("%:p:h") })
  end, { desc = "File File" })
  vim.keymap.set("n", ";r", function()
    require("fzf-lua").live_grep()
  end, { desc = "Live Grep" })
  vim.keymap.set("n", ";;", function()
    require("fzf-lua").lsp_document_diagnostics()
  end, { desc = "Document Diagnostics" })
  vim.keymap.set("n", ";e", function()
    require("fzf-lua").lsp_workspace_diagnostics()
  end, { desc = "Workspace Diagnostics" })
  vim.keymap.set("n", "<leader>ca", function()
    require("fzf-lua").lsp_code_actions()
  end, { desc = "Code Action", silent = true })

  add("folke/which-key.nvim")
  require("which-key").setup({
    preset = "helix",
    spec = {
      {
        mode = { "n", "v" },
        { "<leader><tab>", group = "tabs" },
        { "<leader>c", group = "code" },
        { "<leader>g", group = "git" },
        { "<leader>s", group = "search" },
        { "<leader>u", group = "ui", icon = { icon = "󰙵 ", color = "cyan" } },

        { "z", group = "fold" },
        {
          "<leader>b",
          group = "buffer",
          expand = function()
            return require("which-key.extras").expand.buf()
          end,
        },
        {
          "<leader>w",
          group = "windows",
          proxy = "<c-w>",
          expand = function()
            return require("which-key.extras").expand.win()
          end,
        },
        -- better descriptions
        { "gx", desc = "Open with system app" },
      },
    },
  })
  vim.keymap.set("n", "<leader>?", function()
    require("which-key").show({ global = false })
  end, { desc = "Buffer Keymaps (which-key)" })
  vim.keymap.set("n", "<c-w>?", function()
    require("which-key").show({ keys = "<c-w>", loop = true })
  end, { desc = "Window Hydra Mode (which-key)" })

  add("lewis6991/gitsigns.nvim")
  require("gitsigns").setup()
  add({ source = "kdheepak/lazygit.nvim", depends = { "nvim-lua/plenary.nvim" } }, {})
  vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "LazyGit" })

  -- spellchecker:off
  local M = {}

  ---@type table<string,true>
  M.hl = {}

  M.colors = {
    slate = {
      [50] = "f8fafc",
      [100] = "f1f5f9",
      [200] = "e2e8f0",
      [300] = "cbd5e1",
      [400] = "94a3b8",
      [500] = "64748b",
      [600] = "475569",
      [700] = "334155",
      [800] = "1e293b",
      [900] = "0f172a",
      [950] = "020617",
    },

    gray = {
      [50] = "f9fafb",
      [100] = "f3f4f6",
      [200] = "e5e7eb",
      [300] = "d1d5db",
      [400] = "9ca3af",
      [500] = "6b7280",
      [600] = "4b5563",
      [700] = "374151",
      [800] = "1f2937",
      [900] = "111827",
      [950] = "030712",
    },

    zinc = {
      [50] = "fafafa",
      [100] = "f4f4f5",
      [200] = "e4e4e7",
      [300] = "d4d4d8",
      [400] = "a1a1aa",
      [500] = "71717a",
      [600] = "52525b",
      [700] = "3f3f46",
      [800] = "27272a",
      [900] = "18181b",
      [950] = "09090B",
    },

    neutral = {
      [50] = "fafafa",
      [100] = "f5f5f5",
      [200] = "e5e5e5",
      [300] = "d4d4d4",
      [400] = "a3a3a3",
      [500] = "737373",
      [600] = "525252",
      [700] = "404040",
      [800] = "262626",
      [900] = "171717",
      [950] = "0a0a0a",
    },

    stone = {
      [50] = "fafaf9",
      [100] = "f5f5f4",
      [200] = "e7e5e4",
      [300] = "d6d3d1",
      [400] = "a8a29e",
      [500] = "78716c",
      [600] = "57534e",
      [700] = "44403c",
      [800] = "292524",
      [900] = "1c1917",
      [950] = "0a0a0a",
    },

    red = {
      [50] = "fef2f2",
      [100] = "fee2e2",
      [200] = "fecaca",
      [300] = "fca5a5",
      [400] = "f87171",
      [500] = "ef4444",
      [600] = "dc2626",
      [700] = "b91c1c",
      [800] = "991b1b",
      [900] = "7f1d1d",
      [950] = "450a0a",
    },

    orange = {
      [50] = "fff7ed",
      [100] = "ffedd5",
      [200] = "fed7aa",
      [300] = "fdba74",
      [400] = "fb923c",
      [500] = "f97316",
      [600] = "ea580c",
      [700] = "c2410c",
      [800] = "9a3412",
      [900] = "7c2d12",
      [950] = "431407",
    },

    amber = {
      [50] = "fffbeb",
      [100] = "fef3c7",
      [200] = "fde68a",
      [300] = "fcd34d",
      [400] = "fbbf24",
      [500] = "f59e0b",
      [600] = "d97706",
      [700] = "b45309",
      [800] = "92400e",
      [900] = "78350f",
      [950] = "451a03",
    },

    yellow = {
      [50] = "fefce8",
      [100] = "fef9c3",
      [200] = "fef08a",
      [300] = "fde047",
      [400] = "facc15",
      [500] = "eab308",
      [600] = "ca8a04",
      [700] = "a16207",
      [800] = "854d0e",
      [900] = "713f12",
      [950] = "422006",
    },

    lime = {
      [50] = "f7fee7",
      [100] = "ecfccb",
      [200] = "d9f99d",
      [300] = "bef264",
      [400] = "a3e635",
      [500] = "84cc16",
      [600] = "65a30d",
      [700] = "4d7c0f",
      [800] = "3f6212",
      [900] = "365314",
      [950] = "1a2e05",
    },

    green = {
      [50] = "f0fdf4",
      [100] = "dcfce7",
      [200] = "bbf7d0",
      [300] = "86efac",
      [400] = "4ade80",
      [500] = "22c55e",
      [600] = "16a34a",
      [700] = "15803d",
      [800] = "166534",
      [900] = "14532d",
      [950] = "052e16",
    },

    emerald = {
      [50] = "ecfdf5",
      [100] = "d1fae5",
      [200] = "a7f3d0",
      [300] = "6ee7b7",
      [400] = "34d399",
      [500] = "10b981",
      [600] = "059669",
      [700] = "047857",
      [800] = "065f46",
      [900] = "064e3b",
      [950] = "022c22",
    },

    teal = {
      [50] = "f0fdfa",
      [100] = "ccfbf1",
      [200] = "99f6e4",
      [300] = "5eead4",
      [400] = "2dd4bf",
      [500] = "14b8a6",
      [600] = "0d9488",
      [700] = "0f766e",
      [800] = "115e59",
      [900] = "134e4a",
      [950] = "042f2e",
    },

    cyan = {
      [50] = "ecfeff",
      [100] = "cffafe",
      [200] = "a5f3fc",
      [300] = "67e8f9",
      [400] = "22d3ee",
      [500] = "06b6d4",
      [600] = "0891b2",
      [700] = "0e7490",
      [800] = "155e75",
      [900] = "164e63",
      [950] = "083344",
    },

    sky = {
      [50] = "f0f9ff",
      [100] = "e0f2fe",
      [200] = "bae6fd",
      [300] = "7dd3fc",
      [400] = "38bdf8",
      [500] = "0ea5e9",
      [600] = "0284c7",
      [700] = "0369a1",
      [800] = "075985",
      [900] = "0c4a6e",
      [950] = "082f49",
    },

    blue = {
      [50] = "eff6ff",
      [100] = "dbeafe",
      [200] = "bfdbfe",
      [300] = "93c5fd",
      [400] = "60a5fa",
      [500] = "3b82f6",
      [600] = "2563eb",
      [700] = "1d4ed8",
      [800] = "1e40af",
      [900] = "1e3a8a",
      [950] = "172554",
    },

    indigo = {
      [50] = "eef2ff",
      [100] = "e0e7ff",
      [200] = "c7d2fe",
      [300] = "a5b4fc",
      [400] = "818cf8",
      [500] = "6366f1",
      [600] = "4f46e5",
      [700] = "4338ca",
      [800] = "3730a3",
      [900] = "312e81",
      [950] = "1e1b4b",
    },

    violet = {
      [50] = "f5f3ff",
      [100] = "ede9fe",
      [200] = "ddd6fe",
      [300] = "c4b5fd",
      [400] = "a78bfa",
      [500] = "8b5cf6",
      [600] = "7c3aed",
      [700] = "6d28d9",
      [800] = "5b21b6",
      [900] = "4c1d95",
      [950] = "2e1065",
    },

    purple = {
      [50] = "faf5ff",
      [100] = "f3e8ff",
      [200] = "e9d5ff",
      [300] = "d8b4fe",
      [400] = "c084fc",
      [500] = "a855f7",
      [600] = "9333ea",
      [700] = "7e22ce",
      [800] = "6b21a8",
      [900] = "581c87",
      [950] = "3b0764",
    },

    fuchsia = {
      [50] = "fdf4ff",
      [100] = "fae8ff",
      [200] = "f5d0fe",
      [300] = "f0abfc",
      [400] = "e879f9",
      [500] = "d946ef",
      [600] = "c026d3",
      [700] = "a21caf",
      [800] = "86198f",
      [900] = "701a75",
      [950] = "4a044e",
    },

    pink = {
      [50] = "fdf2f8",
      [100] = "fce7f3",
      [200] = "fbcfe8",
      [300] = "f9a8d4",
      [400] = "f472b6",
      [500] = "ec4899",
      [600] = "db2777",
      [700] = "be185d",
      [800] = "9d174d",
      [900] = "831843",
      [950] = "500724",
    },

    rose = {
      [50] = "fff1f2",
      [100] = "ffe4e6",
      [200] = "fecdd3",
      [300] = "fda4af",
      [400] = "fb7185",
      [500] = "f43f5e",
      [600] = "e11d48",
      [700] = "be123c",
      [800] = "9f1239",
      [900] = "881337",
      [950] = "4c0519",
    },
  }
  -- spellchecker:on

  local hi = require("mini.hipatterns")
  local color_opts = {
    -- custom LazyVim option to enable the tailwind integration
    tailwind = {
      enabled = true,
      ft = {
        "astro",
        "css",
        "heex",
        "html",
        "html-eex",
        "javascript",
        "javascriptreact",
        "rust",
        "svelte",
        "typescript",
        "typescriptreact",
        "vue",
      },
      -- full: the whole css class will be highlighted
      -- compact: only the color will be highlighted
      style = "full",
    },
    highlighters = {
      hex_color = hi.gen_highlighter.hex_color({ priority = 2000 }),
      shorthand = {
        pattern = "()#%x%x%x()%f[^%x%w]",
        group = function(_, _, data)
          ---@type string
          local match = data.full_match
          local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
          local hex_color = "#" .. r .. r .. g .. g .. b .. b

          return MiniHipatterns.compute_hex_color_group(hex_color, "bg")
        end,
        extmark_opts = { priority = 2000 },
      },
    },
  }
  if type(color_opts.tailwind) == "table" and color_opts.tailwind.enabled then
    -- reset hl groups when colorscheme changes
    vim.api.nvim_create_autocmd("ColorScheme", {
      callback = function()
        M.hl = {}
      end,
    })
    color_opts.highlighters.tailwind = {
      pattern = function()
        if not vim.tbl_contains(color_opts.tailwind.ft, vim.bo.filetype) then
          return
        end
        if color_opts.tailwind.style == "full" then
          return "%f[%w:-]()[%w:-]+%-[a-z%-]+%-%d+()%f[^%w:-]"
        elseif color_opts.tailwind.style == "compact" then
          return "%f[%w:-][%w:-]+%-()[a-z%-]+%-%d+()%f[^%w:-]"
        end
      end,
      group = function(_, _, m)
        ---@type string
        local match = m.full_match
        ---@type string, number
        local color, shade = match:match("[%w-]+%-([a-z%-]+)%-(%d+)")
        local nshade = tonumber(shade)
        if nshade then
          local bg = vim.tbl_get(M.colors, color, nshade)
          if bg then
            local hl = "MiniHipatternsTailwind" .. color .. shade
            if not M.hl[hl] then
              M.hl[hl] = true
              local bg_shade = nshade == 500 and 950 or nshade < 500 and 900 or 100
              local fg = vim.tbl_get(M.colors, color, bg_shade)
              vim.api.nvim_set_hl(0, hl, { bg = "#" .. bg, fg = "#" .. fg })
            end
            return hl
          end
        end
      end,
      extmark_opts = { priority = 2000 },
    }
  end
  require("mini.hipatterns").setup(color_opts)

  add({
    source = "chomosuke/typst-preview.nvim",
    hooks = {
      post_checkout = function()
        require("typst-preview").update()
      end,
    },
  })
  if vim.bo.filetype == "typst" then
    require("typst-preview").setup()
  end
end)
