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

vim.opt.tabstop = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smartindent = true

vim.cmd 'set path+=**' -- search for files in subdirectories
vim.opt.syntax = 'ON'

-- Appearance
--------------------

vim.cmd [[colorscheme tokyonight-moon]]
vim.cmd 'highlight LineNrAbove guifg=#3e8287'
vim.cmd 'highlight LineNrBelow guifg=#3f83ab'
vim.api.nvim_set_hl(0, 'StatusLine', { fg = '#3f83ab', bg = '#222337' })
-- vim.api.nvim_set_hl(0, 'StatusLineNC', { fg = '#3f83ab', bg = '#222337' })

-- LSP
--------------------

local lspconfig = require 'lspconfig'
lspconfig.pyright.setup {}
lspconfig.tsserver.setup {}
lspconfig.html.setup {}
lspconfig.cssls.setup {}
lspconfig.jsonls.setup {}
lspconfig['dartls'].setup {}

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

require('luasnip.loaders.from_vscode').lazy_load()
local cmp = require 'cmp'

cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm { select = true }, -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  }),
}

local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig')['dartls'].setup {
  capabilities = capabilities,
}

-- Telescope
--------------------

require('telescope').setup {
  extensions = {
    ['ui-select'] = {
      require('telescope.themes').get_dropdown {},
    },
  },
}

require('telescope').load_extension 'ui-select'

--------------------------------------------------------------------------------
--  Keymaps
--------------------------------------------------------------------------------

-- marks
vim.keymap.set('n', '<C-k>', '[`zz') -- go to previouse mark
vim.keymap.set('n', '<C-j>', ']`zz') -- go to next mark

-- Statusline
--------------------

function DiagnosticStatus()
  local errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
  local warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
  local infos = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
  return string.format(' %d  %d  %d ', errors, warnings, infos)
end
-- local file_icon = "  "
local file_icon = ' '
vim.o.statusline = '%<' .. file_icon .. '%f %h%m%r%=%{v:lua.DiagnosticStatus()} %(%l,%c%V%) %P '

-- Telescope
--------------------

local builtin = require 'telescope.builtin'

-- Diagnostics
vim.keymap.set('n', '<leader>m', builtin.marks, {}) -- m for marks

-- Code Actions

-- Files
vim.keymap.set('n', '<leader>i', builtin.git_files, {}) -- i for in git

-- Telescope UI
local colors = require 'tokyonight.colors'
local TelescopeColor = {
  TelescopeMatching = { fg = colors.flamingo },
  TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },

  TelescopePromptPrefix = { bg = colors.surface0 },
  TelescopePromptNormal = { bg = colors.surface0 },
  TelescopeResultsNormal = { bg = colors.mantle },
  TelescopePreviewNormal = { bg = colors.mantle },
  TelescopePromptBorder = { bg = '#222337', fg = '#3f83ab' },
  TelescopeResultsBorder = { bg = '#222337', fg = '#3f83ab' },
  TelescopePreviewBorder = { bg = '#222337', fg = '#3f83ab' },
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
