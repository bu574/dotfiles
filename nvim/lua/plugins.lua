local fn = vim.fn

-- Automatically install packer
local install_path = fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"
if fn.empty(fn.glob(install_path)) > 0 then
	PACKER_BOOTSTRAP = fn.system({
		"git",
		"clone",
		"--depth",
		"1",
		"https://github.com/wbthomason/packer.nvim",
		install_path,
	})
	print("Installing packer close and reopen Neovim...")
	vim.cmd([[packadd packer.nvim]])
end

-- Autocommand that reloads neovim whenever you save the plugins.lua file
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins.lua source <afile> | PackerSync
  augroup end
]])

-- Use a protected call so we don't error out on first use
local status_ok, packer = pcall(require, "packer")
if not status_ok then
	return
end

-- Have packer use a popup window
packer.init({
	display = {
		open_fn = function()
			return require("packer.util").float({ border = "rounded" })
		end,
	},
})

-- Install your plugins here
return packer.startup(function(use)
	use ("wbthomason/packer.nvim") -- Have packer manage itself	

    use 'williamboman/mason.nvim'
    use 'williamboman/mason-lspconfig.nvim'
    use 'neovim/nvim-lspconfig'

    -- Hrsh7th Code Completion Suite
    use 'hrsh7th/nvim-cmp'
    use 'hrsh7th/cmp-nvim-lsp'
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'hrsh7th/cmp-vsnip'
    use 'hrsh7th/cmp-path'
    use 'hrsh7th/cmp-buffer'
    use 'hrsh7th/vim-vsnip'

    -- Dracula theme for styling
    use 'Mofiqul/dracula.nvim'

    -- File explorer tree
    use {
        'nvim-tree/nvim-tree.lua',
        requires = {
            'nvim-tree/nvim-web-devicons', -- optional, for file icons
        },
    }
    -- DAP for debugging
    use 'mfussenegger/nvim-dap'

    -- UI for DAP
    use { "rcarriga/nvim-dap-ui", requires = {"mfussenegger/nvim-dap"} }

    -- Treesitter
    use {
        -- recommended packer way of installing it is to run this function, copied from documentation
        'nvim-treesitter/nvim-treesitter',
        run = function()
            local ts_update = require('nvim-treesitter.install').update({ with_sync = true })
            ts_update()
        end,
    }

    -- Telescope used to fuzzy search files
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.4',
        requires = { {'nvim-lua/plenary.nvim'} }
    }

    -- Lualine information / Status bar
    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true }
    }

    -- autopairs for brackets etc
    use {
	    "windwp/nvim-autopairs",
	    config = function() require("nvim-autopairs").setup {} end
    }

    use ('nvim-tree/nvim-web-devicons')

    -- tab management plugin 
    use {'akinsho/bufferline.nvim', tag = "*", requires = 'nvim-tree/nvim-web-devicons'}

    -- github.com/mfussenegger/nvim-lint
    -- use ('mfussenegger/nvim-lint')

    -- tagbar to display tags of the current file 
    -- needs dev-util/ctags to be installed
    use ('preservim/tagbar')

    -- vscode like Bottom Error tagbar
    use ('folke/trouble.nvim')

    --display vertical indent lines
    use "lukas-reineke/indent-blankline.nvim"

    use {
        "nathom/filetype.nvim",
        config = function()
            require("filetype").setup {
                overrides = {
                    extensions = {
                        tf = "terraform",
                        tfvars = "terraform",
                        tfstate = "json",
                        yml = "yaml",
                    },
                },
            }

        end,
    }

    --git integration
    use ('tpope/vim-fugitive')

	if PACKER_BOOTSTRAP then
		require("packer").sync()
	end

    --dependency of nvim-dap-ui
    use ('nvim-neotest/nvim-nio')

    --gruvbox theme
    use ('ellisonleao/gruvbox.nvim')

    --nvim linter 
    use 'mfussenegger/nvim-lint'

    --vim-gitgutter
    use 'airblade/vim-gitgutter'

    --github copilot integration
    use {
        'zbirenbaum/copilot.lua',
        cmd = "Copilot",
        event = "InsertEnter",
        }

    --copilot chat integration
    use {
        'CopilotC-Nvim/CopilotChat.nvim',
        dependencies = {
            {'zbirenbaum/copilot.lua'},
            {'nvim-lua/plenary.nvim', branch = 'master'},
        },
        build = 'make-tiktoken', -- only on linux (and macos)
    }
end)
