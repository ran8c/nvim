return {
	cmd = { "rust-analyzer" },
	root_markers = { "Cargo.toml" },
	filetypes = { "rust" },
	capabilities = {
		experimental = {
			serverStatusNotification = true,
		},
	},
	settings = {
		["rust-analyzer"] = {
			check = {
				command = "clippy",
			},
		},
	},
}
