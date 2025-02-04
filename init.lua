local vim = vim
-- 1. VIM-PLUG --------------------------------------------------------------{{{

local Plug = vim.fn['plug#']

vim.call('plug#begin')

  Plug('f-person/git-blame.nvim')
  Plug('kdheepak/lazygit.nvim')
    -- plenary (optional)
  Plug('williamboman/mason.nvim')
    -- mason-lspconfig.nvim (optional)
    -- nvim-lspconfig (optional)
  Plug('hrsh7th/nvim-cmp')
    -- cmp-buffer
    -- cmp-cmdline
    -- cmp-nvim-lsp
    -- cmp-path
    -- nvim-lspconfig
  Plug('nvim-tree/nvim-tree.lua')
    -- nvim-web-devicons (optional)
  Plug('nvim-treesitter/nvim-treesitter', {['do'] = ':TSUpdate'})
  Plug('cpea2506/one_monokai.nvim')
  Plug('rose-pine/neovim')
  Plug('nvim-telescope/telescope.nvim', { ['tag'] = '0.1.8' })
    -- plenary
    -- ripgrep (optional)
    -- telescope-fzf-native (optional)
  Plug('tpope/vim-commentary')
  Plug('tpope/vim-obsession')
  Plug('tpope/vim-rails')
  Plug('vim-ruby/vim-ruby')
  Plug('tpope/vim-sensible')
  Plug('tpope/vim-surround')

--                    ----------- dependancies ----------                     --

  Plug('hrsh7th/cmp-buffer')
    -- nvim-cmp
  Plug('hrsh7th/cmp-cmdline')
    -- nvim-cmp
  Plug('petertriho/cmp-git')
    -- nvim-cmp
  Plug('hrsh7th/cmp-nvim-lsp')
    -- nvim-cmp
  Plug('hrsh7th/cmp-path')
    -- nvim-cmp
  Plug('williamboman/mason-lspconfig.nvim')
    -- mason (optional)
  Plug('neovim/nvim-lspconfig')
    -- mason (optional)
    -- nvim-cmp
  Plug('nvim-tree/nvim-web-devicons')
    -- nvim-tree (optional)
  Plug('nvim-lua/plenary.nvim')
    -- lazygit (optional)
    -- telescope
  Plug('BurntSushi/ripgrep')
    -- telescope (optional)
  Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = 'make' })
    -- telescope (optional)

vim.call('plug#end')

-----------------------------------------------------------------------------}}}
-- 2. PLUG-IN SETUP ---------------------------------------------------------{{{

-- git-blame
require('gitblame').setup {
     --Note how the `gitblame_` prefix is omitted in `setup`
    enabled = true,
}

-- mason
require("mason").setup()

-- nvim-cmp
local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
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
  }, {
    { name = 'buffer' },
  })
})

-- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
 sources = cmp.config.sources({
   { name = 'git' },
 }, {
   { name = 'buffer' },
 })
})
require("cmp_git").setup()

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local lspconfig = require('lspconfig')
local servers = { 'cssls', 'eslint', 'rubocop', 'ruby_lsp', 'somesass_ls', 'ts_ls'}
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    -- on_attach = my_custom_on_attach,
    capabilities = capabilities,
  }
end

-- nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
require("nvim-tree").setup()

-- nvim-treesitter
require('nvim-treesitter.configs').setup{highlight={enable=true}}

--rose-pine
require('rose-pine').setup()

-- telescope
require('telescope').setup{
  defaults = {
    mappings = {
      i = {
        ["<C-d>"] = require("telescope.actions").delete_buffer
      },
      n = {
        ["d"] = require("telescope.actions").delete_buffer
      }

    }
  },
}
require('telescope').load_extension('fzf')

-----------------------------------------------------------------------------}}}
-- 3. APPEARANCE ------------------------------------------------------------{{{

vim.cmd('colorscheme one_monokai')
-- vim.cmd('colorscheme rose-pine-moon')

vim.diagnostic.config({ float = { border = "rounded" } })
vim.wo.number = true
vim.wo.relativenumber = true
vim.opt.colorcolumn = { 80, 140 }
vim.opt.listchars = {
  leadmultispace = "–›\\x20›",
  trail = "¤",
  precedes = "«",
  extends = "»"
}
vim.o.list = true
vim.o.statusline = [[ %<%f\ %h%m%r%=%-14.(%l,%c%V%)\ %P %{ObsessionStatus()}]]

-----------------------------------------------------------------------------}}}
-- 4. FUNCTIONS -----------------------------------------------------------{{{

function centre_panel()
  vim.cmd([[
    lefta vnew
    wincmd w
    exec 'vertical resize '. string(&columns * 0.75)
  ]])
end

function next_terminal_buffer()
  -- Get the list of all buffers
  local buffers = vim.api.nvim_list_bufs()
  -- Get the current buffer
  local current_buf = vim.api.nvim_get_current_buf()
  local found_current = false

  for _, buf in ipairs(buffers) do
    -- Check if the buffer is a terminal
    if vim.bo[buf].buftype == "terminal" then
      if found_current then
        -- Switch to the next terminal buffer
        vim.api.nvim_set_current_buf(buf)
        return
      end
      -- Mark the current terminal buffer as found
      if buf == current_buf then
        found_current = true
      end
    end
  end

  -- If no next terminal buffer was found, wrap around to the first terminal buffer
  for _, buf in ipairs(buffers) do
    if vim.bo[buf].buftype == "terminal" then
      vim.api.nvim_set_current_buf(buf)
      return
    end
  end

  -- No terminal buffers found; open a new vertical terminal
  vim.cmd("terminal")
end

-----------------------------------------------------------------------------}}}
-- 5. START-UP ----------------------------------------------------------------{{{

vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    local session_file = vim.fn.expand("Session.vim")
    if vim.fn.filereadable(session_file) == 1 then
      vim.cmd("source " .. session_file)
    end
  end
})

vim.cmd([[ set sessionoptions+=localoptions ]])

-----------------------------------------------------------------------------}}}
-- 6. EDITOR ----------------------------------------------------------------{{{

vim.o.ignorecase = true
vim.o.foldmethod = "indent"
vim.o.foldlevel = 99

-- indentation
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.smarttab = true
vim.o.softtabstop = -1
vim.o.tabstop = 2

-----------------------------------------------------------------------------}}}
-- 7. KEYMAP ----------------------------------------------------------------{{{

vim.g.mapleader = ' '

--                        ---------- normal ----------                        --

vim.keymap.set('n', '<leader>ce', '<Cmd>edit $MYVIMRC<CR>', { desc = 'Config: edit config' })
vim.keymap.set('n', '<leader>cl', '<Cmd>source $MYVIMRC<CR>', { desc = 'Config: load config' })

vim.keymap.set('n', '<leader>df', '<Cmd>lua vim.diagnostic.open_float()<CR>', { desc = 'Diagnostics: open float' })
vim.keymap.set('n', '<leader>dn', '<Cmd>lua vim.diagnostic.goto_next()<CR>', { desc = 'Diagnostics: go to next' })
vim.keymap.set('n', '<leader>dp', '<Cmd>lua vim.diagnostic.goto_prev()<CR>', { desc = 'Diagnostics: go to previous' })
vim.keymap.set('n', '<leader>dr', '<Cmd>lua vim.diagnostic.reset()<CR>', { desc = 'Diagnostics: reset' })

vim.keymap.set('n', '<leader>kd', '<Cmd>colorscheme one_monokai<CR>', { desc = 'Colour scheme: dark' })
vim.keymap.set('n', '<leader>kl', '<Cmd>colorscheme rose-pine-dawn<CR>', { desc = 'Colour scheme: light' })

vim.keymap.set("n", "<leader>rm", [[0/ \zs{ gncdo/ }$gncendo]], { desc = 'Ruby: convert to multi-line' })
vim.keymap.set("n", "<leader>rs", [[? \zsdo$ciw{v/\W\zsend$Jce }]], { desc = 'Ruby: convert block to single-line' })

vim.keymap.set("n", "<leader>sq", [[:cdo s///g<Left><Left><Left>]], { desc = 'Substitute: replace all in quickfix list' })
vim.keymap.set("n", "<leader>ss", [[:%s///g<Left><Left>]], { desc = 'Substitute: replace all instances with previous search' })

vim.keymap.set("n", "<leader>tb", '<Cmd>term<CR>', { desc = 'Terminal: open terminal in current buffer' })
vim.keymap.set("n", "<leader>tn", next_terminal_buffer, { desc = 'Terminal: switch to next terminal buffer' })
vim.keymap.set("n", "<leader>tw", '<Cmd>rightb vsp | term<CR>', { desc = 'Terminal: open terminal in new window' })

vim.keymap.set('n', '<leader>wc', centre_panel, { desc = 'Window: centre window' })
vim.keymap.set('n', '<leader>wn', '<Cmd>rightb vsp<CR>', { desc = 'Window: new window' })

-- lazygit
vim.keymap.set('n', '<leader>gg', '<Cmd>LazyGit<CR>')

-- nvim-tree
vim.keymap.set('n', '<leader>ec', '<Cmd>NvimTreeCollapse<CR>')
vim.keymap.set('n', '<leader>ef', '<Cmd>NvimTreeFindFile<CR>')
vim.keymap.set('n', '<leader>et', '<Cmd>NvimTreeToggle<CR>')

-- telescope
local tsb = require('telescope.builtin')
vim.keymap.set('n', '<leader>fb', function() tsb.buffers({ sort_mru=true, ignore_current_buffer=true }) end, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fc', tsb.commands, { desc = 'Telescope commands tags'})
vim.keymap.set('n', '<leader>ff', tsb.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', tsb.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fh', tsb.help_tags, { desc = 'Telescope help tags' })

--                        ---------- visual ----------                        --

vim.keymap.set('v', '<leader>cc', '"*y', { desc = 'Copy to clipboard' })

--                       ---------- terminal ----------                       --

vim.keymap.set('t', [[<C-\><C-\>]], [[<C-\><C-n>]], { desc = 'Exit insert mode in terminal'})

-----------------------------------------------------------------------------}}}
-- 8. CONFIG-CONFIG ---------------------------------------------------------{{{

vim.cmd [[ autocmd BufRead,BufNewFile $MYVIMRC setlocal foldmethod=marker | setlocal foldlevel=0 ]]

-----------------------------------------------------------------------------}}}
