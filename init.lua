vim.g.mapleader = " "

-- echasnovski/mini.nvim: a large library of small and excellent lua plugins
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

-- mini.deps: a minimal package manager
require("mini.deps").setup({
	path = {
		package = path_package,
	},
})

-- tpope/vim-fugitive: a git client
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

-- settings for all lsp servers
vim.lsp.config('*', {
	root_markers = { '.git' },
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
