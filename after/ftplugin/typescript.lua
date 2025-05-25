vim.bo.equalprg = "deno fmt -"
vim.bo.makeprg = "{ deno check --quiet % && deno lint --quiet --compact % }"
