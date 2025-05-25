return {
	cmd = { "deno", "lsp" },
	cmd_env = { NO_COLOR = true },
	root_markers = {
		"deno.json",
		"deno.jsonc",
		"node_modules",
		"package.json",
	},
	filetypes = { "javascript", "typescript" },
	settings = {
		deno = {
			enable = true,
			suggest = {
				imports = {
					hosts = { ["https://deno.land"] = true },
				},
			},
		},
	},
}
