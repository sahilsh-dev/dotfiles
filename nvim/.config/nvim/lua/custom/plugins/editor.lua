return {
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    config = function()
      require('rose-pine').setup {
        styles = {
          italic = false, -- Disable italics
        },
        highlight_groups = {
          Comment = { italic = false }, -- Remove italics from comments
          Function = { italic = false }, -- Remove italics from functions
          Keyword = { italic = false }, -- Remove italics from keywords
          Type = { italic = false }, -- Remove italics from types
          Variable = { italic = false }, -- Remove italics from variables
        },
      }

      vim.cmd 'colorscheme rose-pine' -- Apply the theme
    end,
  },
  {
    'goolord/alpha-nvim',
    dependencies = { 'echasnovski/mini.icons' },
    config = function()
      require('alpha').setup(require('alpha.themes.startify').config)
    end,
  },
  {
    'nvim-tree/nvim-tree.lua',
    version = '*',
    lazy = false,
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      require('nvim-tree').setup {}
    end,
  },
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },
}
