vim.opt.encoding = "utf-8"
vim.opt.fileencoding = "utf-8"
vim.wo.number = true

-- # DISABLE netrwPlugin
-- vim.g.loaded_netrw = 1
-- vim.g.loaded_netrwPlugin = 1
vim.g.netrw_preview = 1
vim.g.netrw_liststyle = 3
vim.g.netrw_winsize = 30
vim.g.netrw_bufsettings = "noma nomod nu nobl nowrap ro nornu"

vim.opt.title = true
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.showcmd = true
vim.opt.cmdheight = 1
vim.opt.laststatus = 3
vim.opt.scrolloff = 5
vim.opt.shell = "bash"
vim.opt.relativenumber = true
vim.opt.backupskip = { "/tmp/*", "/private/tmp/*" }
vim.opt.inccommand = "split"
vim.opt.numberwidth = 5
-- Case insensitive searching UNLESS /C or capital in search
vim.opt.ignorecase = true
-- wrap lines
vim.opt.wrap = false
-- Note Pad Style Wrap
vim.cmd("set wrap lbr")

vim.opt.backspace = { "start", "eol", "indent" }
vim.opt.path:append({ "**" }) -- Finding files - Search down into subfolders
vim.opt.wildignore:append({ "*/node_modules/*", "*/__pycache__/*", "*/env/*" })
-- System clipboard
vim.opt.clipboard = { "unnamed", "unnamedplus" }
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.splitkeep = "cursor"

-- Undercurl
vim.cmd([[let &t_Cs = "\e[4:3m"]])
vim.cmd([[let &t_Ce = "\e[4:0m"]])

-- undo
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

-- indent
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.tabstop = 8
vim.opt.shiftwidth = 4
vim.opt.softtabstop = 0
vim.opt.indentexpr = "on"
vim.opt.smarttab = true
vim.opt.breakindent = true

-- Add asterisks in block comments
vim.opt.formatoptions:append({ "r" })

-- go to previous/next line with h,l,left arrow and right arrow
-- when cursor reaches end/beginning of line
vim.opt.whichwrap:append("<>[]hl")

-- use mouse click but disable when typing
vim.opt.mouse = "nvch"
vim.opt.signcolumn = "yes"
vim.api.nvim_set_option_value("colorcolumn", "80", {})
vim.opt.cursorline = true
vim.opt.termguicolors = true
vim.opt.winblend = 0
vim.opt.wildoptions = "pum"
vim.opt.pumblend = 5

-- highlight yanked text for 200ms using the "Visual" highlight group
-- vim.cmd([[
-- augroup highlight_yank
-- autocmd!
-- au TextYankPost * silent! lua vim.highlight.on_yank({higroup="Visual", timeout=100})
-- augroup END
-- ]])

-- Folding
vim.o.foldenable = true
vim.o.foldlevel = 99
vim.o.foldmethod = "expr"
vim.o.foldtext = ""
vim.opt.foldcolumn = "0"
vim.opt.fillchars:append({ fold = " " })
-- Default to treesitter folding
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"
-- Prefer LSP folding if client supports it
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client and client:supports_method("textDocument/foldingRange") then
      local win = vim.api.nvim_get_current_win()
      vim.wo[win][0].foldexpr = "v:lua.vim.lsp.foldexpr()"
    end
  end,
})

vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
-- vim.diagnostic.opt.update_in_insert = true
