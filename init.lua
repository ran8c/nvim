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

-- tpope/vim-fugitive: git client
MiniDeps.add({
	source = "tpope/vim-fugitive",
})
vim.keymap.set("n", "<leader>g", "<cmd>Git<CR>")

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

-- lsp buffer setup
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		-- remove built-in changes to formatexpr
		vim.bo.formatexpr = ""
		-- add extra keymaps (see `:h lsp-defaults`)
		vim.keymap.set("n", "grd", vim.lsp.buf.definition, { buffer = ev.buf })
		vim.keymap.set("n", "grD", vim.lsp.buf.declaration, { buffer = ev.buf })
		vim.keymap.set("n", "grt", vim.lsp.buf.type_defintion, { buffer = ev.buf })
		vim.keymap.set("n", "grf", vim.lsp.buf.format, { buffer = ev.buf })
		vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { buffer = ev.buf })
	end,
})

-- diagnostics setup
vim.diagnostic.config({
	virtual_lines = { current_line = true },
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
