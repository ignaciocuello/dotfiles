require("ignacio")
-- TODO: find out what vim.g... is.move this to it's appropriate place
-- TODO: move this to it's appropriate place.
-- Adds line and relative line to netrw
vim.g.netrw_bufsettings = 'noma nomod nu rnu nobl nowrap ro'

-- TODO: standardise double and single quotes
-- Initialise minpac
vim.cmd.packadd("minpac")
vim.call("minpac#init")

local add = vim.fn['minpac#add']
add('k-takata/minpac', {type = 'opt'})
add('junegunn/fzf')

-- Define user commands for updating/cleaning the plugins.
-- Each of them calls PackInit() to load minpac and register
-- the information of plugins, then performs the task.
vim.cmd [[
  command! PackUpdate call minpac#update()
  command! PackClean call minpac#clean()
  command! PackStatus call minpac#status()
]]
