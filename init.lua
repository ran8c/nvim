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
