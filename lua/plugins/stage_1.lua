-- NOTE: High priority Plugins that need to load first will be here
-- such LSP , treesister and blink cmp
local now = MiniDeps.now
------------------------PLUGIN: treesister--------------------------------
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
