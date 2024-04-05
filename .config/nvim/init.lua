require("ignacio")
-- TODO: find out what vim.g... is.move this to it's appropriate place
-- TODO: move this to it's appropriate place.
-- Adds line and relative line to netrw
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'
--Turn on autocomplete features for vim-ruby
vim.g.rubycomplete_buffer_loading = 1
vim.g.rubycomplete_classes_in_global = 1
vim.g.rubycomplete_rails = 1

-- TODO: standardise double and single quotes
-- Initialise minpac
vim.cmd.packadd("minpac")
vim.call("minpac#init")

-- Highlight yanked text
-- NOTE: Translated by ChatGPT from :h lua-highlight
vim.api.nvim_create_autocmd("TextYankPost", {
    pattern = "*",
    callback = function()
        vim.highlight.on_yank()
    end,
    desc = "Highlight yanked text",
})

local add = vim.fn['minpac#add']
add('k-takata/minpac', {type = 'opt'})
add('junegunn/fzf')
add('catppuccin/nvim', {name = 'catppuccin'})
add('vim-ruby/vim-ruby')
add('tpope/vim-rails')
add('tpope/vim-surround')

-- Define user commands for updating/cleaning the plugins.
-- Each of them calls PackInit() to load minpac and register
-- the information of plugins, then performs the task.
vim.cmd [[
  command! PackUpdate call minpac#update()
  command! PackClean call minpac#clean()
  command! PackStatus call minpac#status()
]]


-- Catpuccin theme
vim.cmd.colorscheme "catppuccin"
