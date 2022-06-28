------ Start-up ------

-- Optimize start-up speed
do
  local ok, impatient = pcall(require, "impatient")

  if not ok then
    vim.notify("impatient.nvim is not installed", vim.log.levels.WARN)
  else
    impatient.enable_profile()
  end
end

-- Setup local aliases
local cmd = vim.cmd
local g = vim.g
local opt = vim.opt

------- Plugins ------

-- Setup Packer for plugin management
local present, packer = pcall(require, "packer")

local first_install = false

if not present then
  local packer_path = vim.fn.stdpath("data") .. "/site/pack/packer/start/packer.nvim"

  print("Cloning packer...")

  vim.fn.delete(packer_path, "rf")
  vim.fn.system({
    "git",
    "clone",
    "https://github.com/wbthomason/packer.nvim",
    "--depth",
    "20",
    packer_path,
  })

  cmd("packadd packer.nvim")
  present, packer = pcall(require, "packer")

  if present then
    print("Packer cloned successfully.")
    first_install = true
  else
    error("Couldn't clone packer !\nPacker path: " .. packer_path .. "\n" .. packer)
  end
end

packer.init({
  display = {
    open_fn = function()
      return require("packer.util").float({ border = "rounded" })
    end,
    prompt_border = "rounded",
  },
  git = { clone_timeout = 800 },
})

local use = packer.use

-- Plugin list and configuration
packer.startup(function()
  -- Startup plugins that don't require configuration
  use({
    "wbthomason/packer.nvim",
    "lewis6991/impatient.nvim",
    "nvim-lua/plenary.nvim",
  })

  -- Color theme
  use({
    "rebelot/kanagawa.nvim",
    as = "kanagawa",
    config = function()
      require("kanagawa").setup({
        commentStyle = { italic = false },
      })
      vim.cmd("colorscheme kanagawa")
    end,
  })

  -- LSP
  use({
    "neovim/nvim-lspconfig",
    after = "cmp-nvim-lsp",
    config = function()
      local lspconfig = require("lspconfig")

      -- Lua
      local runtime_path = vim.split(package.path, ";")
      table.insert(runtime_path, "lua/?.lua")
      table.insert(runtime_path, "lua/?/init.lua")

      lspconfig.sumneko_lua.setup({
        settings = {
          Lua = {
            runtime = {
              version = "LuaJIT",
              -- path = runtime_path
            },
            diagnostics = {
              globals = {"vim"}
            },
            workspace = {
              library = vim.api.nvim_get_runtime_file("", true),
              maxPreload = 100000,
              preloadFileSize = 100000,
            },
            telemetry = {enable = false}
          }
        }
      })
    end
  })

  -- Autocompletion
  use("hrsh7th/cmp-nvim-lsp")
  use("hrsh7th/cmp-buffer")
  use("hrsh7th/cmp-path")
  use("hrsh7th/cmp-cmdline")
  use("hrsh7th/vim-vsnip")
  use("rafamadriz/friendly-snippets")
  use({
    "hrsh7th/nvim-cmp",
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        snippet = {
          expand = function(args)
            vim.fn["vsnip#anonymous"](args.body)
          end,
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = {
          ["<C-n>"] = cmp.mapping(cmp.mapping.select_next_item(), {"i","c"}),
          ["<C-p>"] = cmp.mapping(cmp.mapping.select_prev_item(), {"i","c"}),
          ["<C-d>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<Tab>"] = cmp.mapping(cmp.mapping.confirm({ select = true }), { "i", "c" }),
          ["<CR>"] = cmp.mapping(cmp.mapping.confirm(), { "i", "c" }),
          ["<Esc>"] = cmp.mapping(cmp.mapping.abort(), { "i", "c" }),
        },
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "vsnip" },
        }, {
          { name = "buffer" },
        })
      })

      -- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline("/", {
        sources = {
          { name = "buffer" }
        }
      })

      -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
      cmp.setup.cmdline(":", {
        sources = cmp.config.sources({
          { name = "path" }
        }, {
          { name = "cmdline" }
        })
      })
    end
  })

  -- Treesitter
  use({
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
          disable = {}
        },
        ensure_installed = {
          "lua",
          "markdown"
        },
        rainbow = {
          enable = false,
          extended_mode = true, -- Highlight also non-parentheses delimiters, boolean or table: lang -> boolean
          max_file_lines = 1000, -- Do not enable for files with more than 1000 lines, int
        },
      })
    end
  })

  -- Enhanced comments
  use({
    "numToStr/Comment.nvim",
    config = function()
      require("Comment").setup()
    end,
  })

  -- Automatically sync plugisn on first install
  if first_install then
    packer.sync()
  end
end)

------ Editor ------

-- Indentation
cmd([[
  filetype plugin indent on
]])

local indent = 2

opt.autoindent = true
opt.expandtab = true
opt.shiftwidth = indent
opt.smartindent = true
opt.softtabstop = indent
opt.tabstop = indent

-- Map leader key
g.mapleader = " "

-- Search
opt.hlsearch = false
opt.ignorecase = true
opt.smartcase = true
opt.wildignore = opt.wildignore + { "*/node_modules/*", "*/.git/*", "*/vendor/*" }
opt.wildmenu = true

-- UI
opt.cursorline = true
opt.laststatus = 2
opt.lazyredraw = true
opt.mouse = "a"
opt.number = true
opt.rnu = true
opt.scrolloff = 18
opt.showmode = false
opt.sidescrolloff = 3
opt.signcolumn = "yes"
opt.splitbelow = true
opt.splitright = true
opt.wrap = false

-- Backups
opt.backup = false
opt.swapfile = false
opt.writebackup = false

-- Performance
opt.redrawtime = 1500
opt.timeoutlen = 250
opt.ttimeoutlen = 10
opt.updatetime = 100

-- Theme support
opt.termguicolors = true

-- Autocomplete
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess = opt.shortmess + { c = true }

-- Misc
opt.backspace = { "eol", "start", "indent" }
opt.clipboard = "unnamedplus"
opt.encoding = "utf-8"
opt.matchpairs = { "(:)", "{:}", "[:]", "<:>" }
opt.syntax = "enable"
