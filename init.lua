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

-- Plugin configuration
packer.startup(function()
  -- Startup plugins that don't require configuration
  use({
    "wbthomason/packer.nvim",
    "lewis6991/impatient.nvim",
    "nathom/filetype.nvim",
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
