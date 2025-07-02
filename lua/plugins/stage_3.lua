-- NOTE: Load appearance such as Colorizer, Icons/Themes and Git things
-- *OR* plugin that depend on filetype *OR* per projects
local add = MiniDeps.add

add("windwp/nvim-ts-autotag")
add("akinsho/toggleterm.nvim")
add("ibhagwan/fzf-lua")
add("windwp/nvim-autopairs")
add({
  source = "rayliwell/tree-sitter-rstml",
  hooks = {
    post_checkout = function()
      vim.cmd("TSUpdate")
    end,
  },
}, {})
---------------------------------------------------------------------
local have_autopair, autopair = pcall(require, "nvim-autopairs")
if have_autopair then
  autopair.setup()
end
local have_autotag, autotag = pcall(require, "nvim-ts-autotag")
if have_autopair then
  autotag.setup({
    opts = {
      -- Defaults
      enable_close = true, -- Auto close tags
      enable_rename = true, -- Auto rename pairs of tags
      enable_close_on_slash = false, -- Auto close on trailing </
    },
  })
end

-- PLUGIN: fzf
local have_fzf, fzf = pcall(require, "fzf-lua")
if have_fzf then
  fzf.setup({
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
end

local miniclue = require("mini.clue")
miniclue.setup({
  triggers = {
    -- Leader triggers
    { mode = "n", keys = "<Leader>" },
    { mode = "x", keys = "<Leader>" },

    -- Built-in completion
    { mode = "i", keys = "<C-x>" },

    -- `g` key
    { mode = "n", keys = "g" },
    { mode = "x", keys = "g" },

    { mode = "n", keys = "f" },
    { mode = "x", keys = "f" },

    { mode = "n", keys = ";" },
    { mode = "x", keys = ";" },

    -- Marks
    { mode = "n", keys = "'" },
    { mode = "n", keys = "`" },
    { mode = "x", keys = "'" },
    { mode = "x", keys = "`" },

    -- Registers
    { mode = "n", keys = '"' },
    { mode = "x", keys = '"' },
    { mode = "i", keys = "<C-r>" },
    { mode = "c", keys = "<C-r>" },

    -- Window commands
    { mode = "n", keys = "<C-w>" },

    -- `z` key
    { mode = "n", keys = "z" },
    { mode = "x", keys = "z" },
  },

  clues = {
    -- Enhance this by adding descriptions for <Leader> mapping groups
    miniclue.gen_clues.builtin_completion(),
    miniclue.gen_clues.g(),
    miniclue.gen_clues.marks(),
    miniclue.gen_clues.registers(),
    miniclue.gen_clues.windows(),
    miniclue.gen_clues.z(),
  },
})

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
    fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
    hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
    warn = { pattern = "%f[%w]()WARN()%f[%W]", group = "DiagnosticSignWarn" },
    todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
    note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },

    shorthand = {
      pattern = "()#%x%x%x()%f[^%x%w]",
      group = function(_, _, data)
        ---@type string
        local match = data.full_match
        local r, g, b = match:sub(2, 2), match:sub(3, 3), match:sub(4, 4)
        local hex_color = "#" .. r .. r .. g .. g .. b .. b

        return hi.compute_hex_color_group(hex_color, "bg")
      end,
      extmark_opts = { priority = 2000 },
    },
  },
}
if type(color_opts.tailwind) == "table" and color_opts.tailwind.enabled then
  -- reset hl groups when colorscheme changes
  local hi_colors = require("utils.colors")
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      hi_colors.hl = {}
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
        local bg = vim.tbl_get(hi_colors.colors, color, nshade)
        if bg then
          local hl = "hi_colorsiniHipatternsTailwind" .. color .. shade
          if not hi_colors.hl[hl] then
            hi_colors.hl[hl] = true
            local bg_shade = nshade == 500 and 950 or nshade < 500 and 900 or 100
            local fg = vim.tbl_get(hi_colors.colors, color, bg_shade)
            vim.api.nvim_set_hl(0, hl, { bg = "#" .. bg, fg = "#" .. fg })
          end
          return hl
        end
      end
    end,
    extmark_opts = { priority = 2000 },
  }
end
hi.setup(color_opts)

if vim.bo.filetype == "typst" then
  add({
    source = "chomosuke/typst-preview.nvim",
    hooks = {
      post_checkout = function()
        require("typst-preview").update()
      end,
    },
  })
  require("typst-preview").setup()
end
