---@module neovim configuration
---@author ran8c

vim.g.mapleader = " "

-- echasnovski/mini.nvim: large library of small and excellent lua plugins
local path_package = vim.fn.stdpath("data") .. "/site"
local mini_path = path_package .. "/pack/deps/start/mini.nvim"
if not vim.loop.fs_stat(mini_path) then
	vim.cmd('echo "Installing `mini.nvim`" | redraw')
	local clone_cmd = {
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/echasnovski/mini.nvim",
		mini_path,
	}
	vim.fn.system(clone_cmd)
	vim.cmd("packadd mini.nvim | helptags ALL")
end

-- mini.deps: minimal package manager
require("mini.deps").setup({
	path = {
		package = path_package,
	},
})

-- mini.completion: popup completion
require("mini.completion").setup({
	delay = {
		completion = 250,
		info = 100,
		signature = 50,
	},
})

-- mini.align: interactive text alignment
require("mini.align").setup({
	mappings = {
		start = "gA",
		start_with_preview = "ga",
	},
})

-- mini.surround: manage delimiters
require("mini.surround").setup()

-- mini.clue: show available keymaps
local miniclue = require("mini.clue")
miniclue.setup({
	triggers = {
		-- Leader triggers
		{ mode = "n", keys = "<Leader>" },
		{ mode = "x", keys = "<Leader>" },
		-- Built-in completion
		{ mode = "i", keys = "<C-x>" },
		-- `g` key
		{ mode = "n", keys = "g" },
		{ mode = "x", keys = "g" },
		-- Marks
		{ mode = "n", keys = "'" },
		{ mode = "n", keys = "`" },
		{ mode = "x", keys = "'" },
		{ mode = "x", keys = "`" },
		-- Registers
		{ mode = "n", keys = '"' },
		{ mode = "x", keys = '"' },
		{ mode = "i", keys = "<C-r>" },
		{ mode = "c", keys = "<C-r>" },
		-- Window commands
		{ mode = "n", keys = "<C-w>" },
		-- `z` key
		{ mode = "n", keys = "z" },
		{ mode = "x", keys = "z" },
	},
	clues = {
		-- Enhance this by adding descriptions for <Leader> mapping groups
		miniclue.gen_clues.builtin_completion(),
		miniclue.gen_clues.g(),
		miniclue.gen_clues.marks(),
		miniclue.gen_clues.registers(),
		miniclue.gen_clues.windows(),
		miniclue.gen_clues.z(),
	},
})

-- mini.jump: improved find/till behavior
require("mini.jump").setup()

-- mini.statusline: pretty bottom line
require("mini.statusline").setup({ use_icons = false })
vim.o.showmode = false

-- mini.pick: fuzzy finder
require("mini.pick").setup({
	source = { show = require("mini.pick").default_show },
})
require("mini.extra").setup()
local minipick_keymap = function(key, func, desc)
	local desc = "Pick: " .. desc
	vim.keymap.set("n", key, func, { desc = desc })
end
local minipick_lsp_keymap = function(key, scope, desc)
	local desc = "LSP: " .. desc
	vim.keymap.set("n", key, function()
		MiniExtra.pickers.lsp(scope)
	end, { desc = desc })
end
minipick_keymap("<leader>ff", MiniPick.builtin.files, "Files")
minipick_keymap("<leader>fF", MiniExtra.pickers.git_files, "Git files")
minipick_keymap("<leader>fg", MiniPick.builtin.grep_live, "Grep")
minipick_keymap("<leader>fh", MiniPick.builtin.help, "Helptags")
minipick_keymap("<leader>fb", MiniPick.builtin.buffers, "Buffers")
minipick_keymap("<leader>f/", MiniExtra.pickers.buf_lines, "Lines")
minipick_keymap("<leader>fd", MiniExtra.pickers.diagnostic, "Diagnostics")
minipick_lsp_keymap("<leader>flr", "references", "References")
minipick_lsp_keymap("<leader>fls", "workspace_symbol", "Symbols")
minipick_keymap('<leader>"', MiniExtra.pickers.registers, "Registers")
minipick_keymap("<leader>fz", MiniExtra.pickers.spellsuggest, "Spellcheck")

-- tpope/vim-fugitive: git client
MiniDeps.add({
	source = "tpope/vim-fugitive",
})
vim.keymap.set("n", "<leader>g", "<cmd>Git<CR>", { desc = "Git" })

-- nvim-treesitter/nvim-treesitter: improved code parsing library
MiniDeps.add({
	source = "nvim-treesitter/nvim-treesitter",
	hooks = {
		post_checkout = function()
			vim.cmd("TSUpdate")
		end,
	},
})
require("nvim-treesitter.configs").setup({
	sync_install = false,
	ensure_installed = { "lua", "vimdoc", "markdown", "gitcommit" },
	auto_install = true,
	highlight = { enable = true },
})
vim.api.nvim_create_autocmd("BufReadPost", {
	-- defer setting up treesitter folds until later
	callback = function()
		vim.defer_fn(function()
			vim.o.foldmethod = "expr"
			vim.o.foldmethod = "expr"
			vim.o.foldexpr = "nvim_treesitter#foldexpr()"
			-- vim.o.foldcolumn = "1"
			vim.o.foldnestmax = 3
			vim.o.foldlevel = 99
			vim.o.foldlevelstart = 99
		end, 100)
	end,
})

-- danymat/neogen: annotation generator
MiniDeps.add({ source = "danymat/neogen" })
require("neogen").setup()
vim.keymap.set("n", "<leader>a", "<cmd>Neogen<CR>", { desc = "Annotate..." })
vim.keymap.set("n", "<leader>A", "<cmd>Neogen file<CR>", { desc = "Annotate file" })

-- built-in vim settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"

vim.o.textwidth = 79
vim.o.colorcolumn = "+1"

vim.o.expandtab = false
vim.o.tabstop = 4
vim.o.softtabstop = 0
vim.o.shiftwidth = 0

vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true

-- use <C-c> as alias for <Esc>
vim.keymap.set({ "", "i" }, "<C-c>", "<Esc>")

-- quickly lint current buffer (see `:h makeprg`)
vim.keymap.set("n", "<leader>m", "<cmd>make<CR>", { desc = "Lint buffer" })

-- lsp buffer setup
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		-- remove built-in changes to formatexpr
		vim.bo.formatexpr = ""
		-- add extra keymaps (see `:h lsp-defaults`)
		local lsp_keymap = function(key, func, desc)
			local desc = "LSP: " .. desc
			vim.keymap.set("n", key, func, { desc = desc, buffer = ev.buf })
		end
		lsp_keymap("grd", vim.lsp.buf.definition, "Goto definition")
		lsp_keymap("grD", vim.lsp.buf.declaration, "Goto declaration")
		lsp_keymap("grt", vim.lsp.buf.type_definition, "Goto type definition")
		lsp_keymap("grf", vim.lsp.buf.format, "Format")
		lsp_keymap("<leader>d", vim.diagnostic.open_float, "Popup diagnostic")
	end,
})

-- diagnostics setup
vim.diagnostic.config({
	virtual_text = { current_line = true },
})

-- settings for all lsp servers
vim.lsp.config("*", {
	root_markers = { ".git" },
})

-- hide all lsp semantic highlights
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
	vim.api.nvim_set_hl(0, group, {})
end

-- enable all configured lsp servers
local lsp_servers = {}
do
	local lsp_server_runtimes = vim.api.nvim_get_runtime_file("lsp/*.lua", true)
	for _, f in pairs(lsp_server_runtimes) do
		local lsp_server_name = vim.fn.fnamemodify(f, ":t:r")
		table.insert(lsp_servers, lsp_server_name)
	end
end
vim.lsp.enable(lsp_servers)
