---@module neovim configuration
---@author ran8c
---@license MIT License

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

-- tpope/vim-fugitive: git client
MiniDeps.add({
	source = "tpope/vim-fugitive",
})
vim.keymap.set("n", "<leader>g", "<cmd>Git<CR>", { desc = "Git" })

-- colorscheme
MiniDeps.add({ source = "cocopon/iceberg.vim" })
vim.cmd.colorscheme("iceberg")
vim.cmd("highlight LineNr guibg=none ctermbg=none")
vim.cmd("highlight SignColumn guibg=none ctermbg=none")

-- built-in vim settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.signcolumn = "yes"
vim.o.winborder = "double"

vim.o.textwidth = 79
vim.o.colorcolumn = "+1"

vim.o.expandtab = false
vim.o.tabstop = 4
vim.o.softtabstop = 0
vim.o.shiftwidth = 0

vim.o.hlsearch = false
vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.path = vim.o.path .. "**"
vim.o.wildmenu = true

-- command abbreviations
vim.keymap.set("ca", "e", "edit")
vim.keymap.set("ca", "f", "find")

-- use <C-c> as alias for <Esc>
vim.keymap.set({ "", "i" }, "<C-c>", "<Esc>")

-- switch modes like normal in terminal
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>")

-- quickly lint current buffer (see `:h makeprg`)
vim.keymap.set("n", "<leader>m", "<cmd>make<CR>", { desc = "Lint buffer" })
vim.keymap.set("n", "<leader>M", ":let &makeprg=''", { desc = "Set linter" })

-- format current buffer
vim.keymap.set("n", "<leader>=", "mzgg=G`z", { desc = "Format buffer" })
vim.keymap.set("n", "<leader>+", ":let &equalprg=''", { desc = "Set formatter" })

-- control the quickfix list
vim.keymap.set("n", "<leader>q", "<cmd>copen<CR>", { desc = "Open qflist" })
vim.keymap.set("n", "<leader>Q", "<cmd>cclose<CR>", { desc = "Close qflist" })

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
		lsp_keymap("grr", vim.lsp.buf.rename, "Rename")
		lsp_keymap("D", vim.diagnostic.open_float, "Popup diagnostic")
	end,
})

-- diagnostics setup
vim.diagnostic.config({
	virtual_text = { current_line = true },
})

-- settings for all lsp servers
vim.lsp.config("*", {
	root_markers = { ".git" },
	server_capabilities = {
		semanticTokensProvider = nil,
	},
})

-- hide all lsp semantic highlights
for _, group in ipairs(vim.fn.getcompletion("@lsp", "highlight")) do
	vim.api.nvim_set_hl(0, group, {})
end

-- enable all configured lsp servers
local lsp_enabled = true
if lsp_enabled then
	local lsp_servers = {}
	local lsp_server_runtimes = vim.api.nvim_get_runtime_file("lsp/*.lua", true)
	for _, f in pairs(lsp_server_runtimes) do
		local lsp_server_name = vim.fn.fnamemodify(f, ":t:r")
		table.insert(lsp_servers, lsp_server_name)
	end
	vim.lsp.enable(lsp_servers)
end
