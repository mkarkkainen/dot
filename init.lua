local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.opt.termguicolors = true
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
vim.opt.rtp:prepend(vim.env.LAZY or lazypath)

require('lazy').setup({

    { 'rose-pine/neovim',                 name = 'rose-pine' },
    { "tpope/vim-fugitive" },
    { 'williamboman/mason.nvim' },
    { 'williamboman/mason-lspconfig.nvim' },
    { -- LSP Support
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v3.x',
        lazy = true,
        config = function()
            local lsp = require("lsp-zero")

            lsp.preset("recommended")

            lsp.on_attach(function(_, bufnr)
                local opts = { buffer = bufnr, remap = false }

                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)
                vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)
                vim.keymap.set("n", "dn", vim.diagnostic.goto_next, opts)
                vim.keymap.set("n", "dp", vim.diagnostic.goto_prev, opts)
                vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)
                vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)
                vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)
                vim.keymap.set("i", "<C-h>", vim.lsp.buf.signature_help, opts)
            end)

            lsp.setup()

            local cmp = require("cmp")

            cmp.setup({
                mapping = {
                    ["<CR>"] = cmp.mapping.confirm({ select = false }),
                    ["<C-Space>"] = cmp.mapping.complete(),
                }
            })

            vim.opt.termguicolors = true

            vim.diagnostic.config({
                virtual_text = true,
            })
        end,
        keys = {
            { "<leader>i", "<cmd>LspInfo<cr>",    "Lsp Info" },
            { "<leader>I", "<cmd>LspInstall<cr>", "Lsp Install" },
        },
    },

    { -- LSP Config
        'neovim/nvim-lspconfig',
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
        },
       
    },

    { -- Autocompletion
        'hrsh7th/nvim-cmp',
        dependencies = {
            { 'L3MON4D3/LuaSnip' }
        },
    },

    { -- Use which-key to show lsp_zero default_keymaps
        'folke/which-key.nvim',
        event = "VeryLazy",
        config = function()
            require('which-key').setup(
                { plugins = { spelling = true } }
            )
        end,
    },
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        dependencies = { 'nvim-lua/plenary.nvim' },
        cmd = "Telescope",
        keys = {
            { "<leader>ff", "<cmd>Telescope find_files<cr>" },
            { "<leader>fg", "<cmd>Telescope live_grep<cr>" },
            { "<C-p>",      "<cmd>Telescope git_files<cr>" }
        },
    },
    {
        'nvim-treesitter/nvim-treesitter',
        'nvim-treesitter/playground',
        build = ':TSUpdate',
        config = function()
            local configs = require('nvim-treesitter.configs')

            configs.setup({
                ensure_installed = 'all',
                sync_install = false,
                auto_install = true,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false
                },
            })
        end,
    },

    {
        "theprimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("harpoon"):setup()
        end,
        keys = {
            { "<leader>A", function() require("harpoon"):list():append() end,  desc = "harpoon file", },
            {
                "<leader>a",
                function()
                    local harpoon = require("harpoon")
                    harpoon.ui:toggle_quick_menu(harpoon:list())
                end,
                desc = "harpoon quick menu",
            },
            { "<leader>1", function() require("harpoon"):list():select(1) end, desc = "harpoon to file 1", },
            { "<leader>2", function() require("harpoon"):list():select(2) end, desc = "harpoon to file 2", },
            { "<leader>3", function() require("harpoon"):list():select(3) end, desc = "harpoon to file 3", },
            { "<leader>4", function() require("harpoon"):list():select(4) end, desc = "harpoon to file 4", },
            { "<leader>5", function() require("harpoon"):list():select(5) end, desc = "harpoon to file 5", },
        },
    }

})


require("config.keymaps")
require("config.set")

-- Use lsp_zero to manage lsp attachments.
local lsp_zero = require('lsp-zero')
lsp_zero.on_attach(function(_, bufnr)
    lsp_zero.default_keymaps({ buffer = bufnr })
end)

-- Setup Mason and Mason-Config.
require('mason').setup({})
require('mason-lspconfig').setup({
    handlers = {
        lsp_zero.default_setup,
        lua_ls = function()
            local lua_opts = lsp_zero.nvim_lua_ls()
            require('lspconfig').lua_ls.setup(lua_opts)
        end,
    },
})

require 'lspconfig'.astro.setup({
    init_options = {
        typescript = {
            tsdk = vim.fs.normalize('/usr/local/lib/node_modules/typescript/lib/')
        }
    },
})

require 'lspconfig'.gopls.setup({})
-- require'lspconfig'.astro.setup { init_options = { on_attach = on_attach, capabilities = capabilities, configuration = {}, typescript = { serverPath = vim.fs.normalize '/usr/local/lib/node_modules/typescript/lib/tsserverlibrary.js', }, }, }

function ColorMyPencil(color)
    color = color or "rose-pine"
    vim.cmd.colorscheme(color)

    vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

ColorMyPencil()
