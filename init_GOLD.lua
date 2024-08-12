-------------------------------------------------------------------------------
--  Cheat Sheet
-------------------------------------------------------------------------------

-- *  : search word under cursor
-- ; : repeat last f, F, t, or T
-- , : repeat last f, F, t, or T in opposite direction

-- C-k: jump to mark
-- C-j: jump to mark

-- dö: previous diagnostic
-- dä: next diagnostic

-- za: toggle fold
-- zc: close fold
-- zo: open fold
-- zr: reduce fold
-- zR: reduce all folds
-- zm: more fold
-- zM: more all folds

-- gi: go to implementation
-- K: hover
-- gD: go to declaration

-- kerminal Shortcuts:
--------------------------

-- C-p: previous command
-- C-n: next command
-- C-s: tmux leader
-- C-b: back one character
-- C-f: forward one character
-- C-c: cancel command
-- C-l: clear screen
-- C-r: search history
-- C-a: beginning of line
-- C-e: end of line

--------------------------------------------------------------------------------
--  General
--------------------------------------------------------------------------------

vim.g.mapleader = " "
vim.g.maplocalleader = ' '
vim.opt.relativenumber = true

vim.opt.compatible = false -- turn off vi compatibility
vim.opt.mouse = 'a'

vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true
vim.opt.wrap = false -- don't wrap lines

vim.opt.scrolloff = 7
vim.opt.sidescrolloff = 7

vim.opt.clipboard = "unnamedplus" -- copy to system clipboard

vim.opt.ignorecase = true -- ignore case when searching
vim.opt.smartcase = true -- ignore case when searching, unless capital letter is used

-- Set highlight on search, but clear on pressing <Esc> in normal mode
vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

vim.opt.foldmethod = 'indent' -- fold based on indent
vim.opt.foldlevel = 99 -- open all folds by default

--vim.g.netrw_banner = 0 -- no banner
vim.g.netrw_liststyle = 3 -- tree view

vim.cmd("set path+=**") -- search for files in subdirectories
vim.opt.syntax = "ON"

vim.opt.splitright = true -- open new split to the right
vim.opt.splitbelow = true -- open new split below

vim.opt.updatetime = 150 -- update time in ms
vim.opt.timeoutlen = 200 -- time to wait for keymap to complete

--------------------------------------------------------------------------------
--  Packages Definition
--------------------------------------------------------------------------------

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- define plugins
local plugins = {
  {'folke/tokyonight.nvim', lazy = false},
  { "tpope/vim-fugitive" },
  {"nvim-treesitter/nvim-treesitter", build = ":TSUpdate",
    config = function () 
      local configs = require("nvim-treesitter.configs")
      configs.setup({
        ensure_installed = { "lua", "typescript", "javascript", "dart", "html", "css", "python" },
        highlight = { enable = true },
        indent = { enable = true },  
      })
    end
  },
  {'neovim/nvim-lspconfig'},
  {'hrsh7th/nvim-cmp'},
  {'hrsh7th/cmp-nvim-lsp'},
  {
    "L3MON4D3/LuaSnip",
    dependencies = { "rafamadriz/friendly-snippets" },
  },
  { "github/copilot.vim" },
  { "nvim-telescope/telescope.nvim",
    tag = "0.1.6",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
  { "nvim-telescope/telescope-ui-select.nvim" },
}

require("lazy").setup(plugins, {})

--------------------------------------------------------------------------------
--  Packages Setup
--------------------------------------------------------------------------------

-- Appearance
--------------------

vim.cmd([[colorscheme tokyonight-moon]])
vim.cmd('highlight LineNrAbove guifg=#3e8287')
vim.cmd('highlight LineNrBelow guifg=#3f83ab')
vim.api.nvim_set_hl(0, 'StatusLine', { fg = '#3f83ab', bg = '#222337' })
-- vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = '#3f83ab', bg = '#222337' })

-- LSP
--------------------

local lspconfig = require("lspconfig")
lspconfig.pyright.setup {}
lspconfig.tsserver.setup {}
lspconfig.html.setup {}
lspconfig.cssls.setup {}
lspconfig.jsonls.setup {}
lspconfig["dartls"].setup({})

-- Format on save
vim.api.nvim_create_augroup('AutoFormatting', {})
vim.api.nvim_create_autocmd('BufWritePre', {
  group = 'AutoFormatting',
  callback = function()
    vim.lsp.buf.format()
  end,
})

--  Completion  
---------------------

require("luasnip.loaders.from_vscode").lazy_load()
local cmp = require('cmp')

cmp.setup({
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body) 
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' }, 
  }, {
      { name = 'buffer' },
    })
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig')['dartls'].setup {
  capabilities = capabilities
}

-- Telescope
--------------------

require("telescope").setup {
  extensions = {
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {}
    }
  }
}

require("telescope").load_extension("ui-select")

--------------------------------------------------------------------------------
--  Keymaps
--------------------------------------------------------------------------------

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- marks
vim.keymap.set("n", "<C-k>", "[`zz") -- go to previouse mark
vim.keymap.set("n", "<C-j>", "]`zz") -- go to next mark

-- save and quit
vim.keymap.set("i", "jj", "<Esc>")
vim.keymap.set("i", "kk", "<Esc>:w<CR>")
vim.keymap.set("n", "<leader>s", ":w<CR>") -- s for save
vim.keymap.set("n", "<leader>a", ":bd<CR>") -- a for abort (quit) buffer
vim.keymap.set("n", "<leader>q", ":q<CR>") -- q for quit
vim.keymap.set("n", "<leader>w", ":wq<CR>") -- w for write and quit

-- file explorer
vim.keymap.set("n", "<leader>t", ":Explore<CR>") -- t for tree

-- git
-- vim.keymap.set("n", "<leader>g", ":vertical Git<CR>:vertical resize 60<CR>") -- g for git
vim.keymap.set("n", "<leader>g", ":Git<CR>") -- g for git
vim.keymap.set("n", "<leader>d", vim.cmd.Gvdiffsplit) -- d for diff
vim.keymap.set("n", "<leader>p", ":G push origin<CR>") -- p for push

-- lsp
vim.keymap.set('n', 'ge', vim.diagnostic.goto_prev)
--vim.keymap.set('n', 'gä', vim.diagnostic.goto_next)

vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- hit K twice enters sub-window
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<leader>r", vim.lsp.buf.rename, opts) -- r for rename
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
  end,
})

-- Statusline
--------------------

function DiagnosticStatus()
    local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    local infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    return string.format(" %d  %d  %d ", errors, warnings, infos)
end
-- local file_icon = "  "
local file_icon = " "
vim.o.statusline = "%<" .. file_icon .. "%f %h%m%r%=%{v:lua.DiagnosticStatus()} %(%l,%c%V%) %P "


-- Telescope
--------------------

local builtin = require('telescope.builtin')

-- Diagnostics
vim.keymap.set('n', '<leader>e', builtin.diagnostics, {}) -- e for errors
vim.keymap.set('n', '<leader>ö', vim.diagnostic.goto_next, {}) -- ä for errors
vim.keymap.set('n', '<leader>m', builtin.marks, {}) -- m for marks

-- Code Actions
vim.keymap.set("n", "<leader>c", function()  -- c for code actions
  vim.lsp.buf.code_action({ border = "rounded" }) 
end)

-- Files
vim.keymap.set('n', '<leader>f', builtin.live_grep, {}) -- f for find
vim.keymap.set('n', '<leader>o', builtin.find_files, {}) -- o for open
vim.keymap.set('n', '<leader>i', builtin.git_files, {}) -- i for in git

-- Buffers
vim.keymap.set('n', '<leader>b', builtin.buffers, {}) -- b for buffers

-- Telescope UI
local colors = require("tokyonight.colors")
local TelescopeColor = {
	TelescopeMatching = { fg = colors.flamingo },
	TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },

	TelescopePromptPrefix = { bg = colors.surface0 },
	TelescopePromptNormal = { bg = colors.surface0 },
	TelescopeResultsNormal = { bg = colors.mantle },
	TelescopePreviewNormal = { bg = colors.mantle },
	TelescopePromptBorder = { bg = "#222337", fg = "#3f83ab" },
	TelescopeResultsBorder = { bg = "#222337", fg = "#3f83ab" },
	TelescopePreviewBorder = { bg = "#222337", fg = "#3f83ab" },
	TelescopePromptTitle = { bg = colors.pink, fg = colors.mantle },
	TelescopeResultsTitle = { fg = colors.mantle },
	TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },
}

for hl, col in pairs(TelescopeColor) do
	vim.api.nvim_set_hl(0, hl, col)
end

-- Same without Telescope
--vim.keymap.set('n', '<leader>e', vim.diagnostic.goto_next, {}) -- e for errors
--vim.keymap.set('n', '<leader>m', ':marks<CR>', {}) -- m for marks
--vim.keymap.set('n', '<leader>c', vim.lsp.buf.code_action, {}) -- m for marks
--vim.keymap.set('n', '<leader>o', ':find ', {}) -- o for open
--vim.keymap.set('n', '<leader>b', ':buffers<CR>', {}) -- b for buffers

-- Buffer Navigation
vim.keymap.set('n', '<C-h>', ':bprevious<CR>', {})
vim.keymap.set('n', '<C-l>', ':bnext<CR>', {})

-- Leap
--------------------
-- vim.keymap.set('n',        's', '<Plug>(leap)')
-- vim.keymap.set('n',        'S', '<Plug>(leap-from-window)')
-- vim.keymap.set({'x', 'o'}, 's', '<Plug>(leap-forward)')
-- vim.keymap.set({'x', 'o'}, 'S', '<Plug>(leap-backward)')
-- require("leap").opts.safe_labels = 'sfnut'
-- require("leap").opts.safe_labels = 'sfnjklhodweimbuyvrgtaqpcxz'
