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
if string.match(path, "mason") then
  later(mason_setup)
else 
  now(mason_setup)
end

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
      default = { "lsp", "path", "snippets", "buffer", "omni" },
      providers = {
        lsp = {
          name = "LSP",
          module = "blink.cmp.sources.lsp",

          --- NOTE: All of these options may be functions to get dynamic behavior
          --- See the type definitions for more information
          enabled = true,           -- Whether or not to enable the provider
          async = true,             -- Whether we should show the completions before this provider returns, without waiting for it
          timeout_ms = 2000,        -- How long to wait for the provider to return before showing completions and treating it as asynchronous
          transform_items = nil,    -- Function to transform the items before they're returned
          should_show_items = true, -- Whether or not to show the items
          max_items = nil,          -- Maximum number of items to display in the menu
          min_keyword_length = 0,   -- Minimum number of characters in the keyword to trigger the provider
          -- If this provider returns 0 items, it will fallback to these providers.
          -- If multiple providers fallback to the same provider, all of the providers must return 0 items for it to fallback
          fallbacks = { "buffer" },
          score_offset = 99, -- Boost/penalize the score of the items
          override = nil,    -- Override the source's functions
        },
      },
    },
    fuzzy = {
      implementation = "rust",
      prebuilt_binaries = { force_version = "v1.4.1" },
      sorts = {
        function(a, b)
          if a.label:sub(1, 1) == "_" ~= a.label:sub(1, 1) == "_" then
            -- return true to sort `a` after `b`, and vice versa
            return not a.label:sub(1, 1) == "_"
          end
          -- nothing returned, fallback to the next sort
        end,
        "exact",
        "score",
        "sort_text",
      },
    },
  })

  ------------------------PLUGIN: LSP --------------------------------
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

      ruff = {
        on_attach = function(client, _bufnr)
          if client.name == "ruff_lsp" then
            -- Disable hover in favor of Pyright
            client.server_capabilities.hoverProvider = false
          end
        end,
      },
      vtsls = { enabled = false },
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

      ts_ls = {
        -- root_dir = function(...)
        --   return require("lspconfig.util").root_pattern(".git")(...)
        -- end,
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
      html = {},
      phpactor = {
        enabled = true,
      },
      marksman = {},

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
