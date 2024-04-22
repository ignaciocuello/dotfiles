-- NOTE: `:help lua-guide`
-- NOTE: "<space>sh" to [s]earch the [h]elp documentation

vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.g.have_nerd_font = true

-- [[ Setting options ]]

-- Make line numbers default
vim.opt.number = true
-- Enable relative line numbers
vim.opt.relativenumber = true

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Sync clipboard between OS and Neovim.
vim.opt.clipboard = "unnamedplus"

-- Save undo history
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- NOTE: unsure if this is used for something else
-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- Displays which-key popup sooner
vim.opt.timeoutlen = 300

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Highlight column at 81st and 121st position
vim.opt.colorcolumn = "81,121"

-- [[ Basic Keymaps ]]
--  See `:help vim.keymap.set()`

-- Set highlight on search
vim.opt.hlsearch = true
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlights" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Move cursor up half a page" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Move cursor down half a page" })

-- Keybinds to make split navigation easier.
--  Use CTRL+<hjkl> to switch between windows
--
--NOTE: Not sure how I feel about these? I wonder if they override normal keybinds?
--  See `:help wincmd` for a list of all window commands
vim.keymap.set("n", "<C-h>", "<C-w><C-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<C-l>", "<C-w><C-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<C-j>", "<C-w><C-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<C-k>", "<C-w><C-k>", { desc = "Move focus to the upper window" })

-- Keybind to make terminals easier
vim.keymap.set("n", "<leader>cv", ":vsplit | terminal<CR>", { desc = "Open terminal in vertical split" })
vim.keymap.set("n", "<leader>cs", ":split | terminal<CR>", { desc = "Open terminal in horizontal split" })

-- Disable wrapping
vim.opt.wrap = false

-- [[ Basic Autocommands ]]
--  See `:help lua-guide-autocommands`

-- Highlight when yanking (copying) text
-- Group important for not doubling up on re-source (clear = true)
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"--branch=stable",
		lazyrepo,
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins")

-- TODO: READ FURTHER!!!
-- textDocument/diagnostic support until 0.10.0 is released
_timers = {}
local function setup_diagnostics(client, buffer)
	if require("vim.lsp.diagnostic")._enable then
		return
	end

	local diagnostic_handler = function()
		local params = vim.lsp.util.make_text_document_params(buffer)
		client.request("textDocument/diagnostic", { textDocument = params }, function(err, result)
			if err then
				local err_msg = string.format("diagnostics error - %s", vim.inspect(err))
				vim.lsp.log.error(err_msg)
			end
			local diagnostic_items = {}
			if result then
				diagnostic_items = result.items
			end
			vim.lsp.diagnostic.on_publish_diagnostics(
				nil,
				vim.tbl_extend("keep", params, { diagnostics = diagnostic_items }),
				{ client_id = client.id }
			)
		end)
	end

	diagnostic_handler() -- to request diagnostics on buffer when first attaching

	vim.api.nvim_buf_attach(buffer, false, {
		on_lines = function()
			if _timers[buffer] then
				vim.fn.timer_stop(_timers[buffer])
			end
			_timers[buffer] = vim.fn.timer_start(200, diagnostic_handler)
		end,
		on_detach = function()
			if _timers[buffer] then
				vim.fn.timer_stop(_timers[buffer])
			end
		end,
	})
end

-- adds ShowRubyDeps command to show dependencies in the quickfix list.
-- add the `all` argument to show indirect dependencies as well
local function add_ruby_deps_command(client, bufnr)
	vim.api.nvim_buf_create_user_command(bufnr, "ShowRubyDeps", function(opts)
		local params = vim.lsp.util.make_text_document_params()

		local showAll = opts.args == "all"

		client.request("rubyLsp/workspace/dependencies", params, function(error, result)
			if error then
				print("Error showing deps: " .. error)
				return
			end

			local qf_list = {}
			for _, item in ipairs(result) do
				if showAll or item.dependency then
					table.insert(qf_list, {
						text = string.format("%s (%s) - %s", item.name, item.version, item.dependency),

						filename = item.path,
					})
				end
			end

			vim.fn.setqflist(qf_list)
			vim.cmd("copen")
		end, bufnr)
	end, {
		nargs = "?",
		complete = function()
			return { "all" }
		end,
	})
end

require("lspconfig").ruby_ls.setup({
	on_attach = function(client, buffer)
		setup_diagnostics(client, buffer)
		add_ruby_deps_command(client, buffer)
	end,
})
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
